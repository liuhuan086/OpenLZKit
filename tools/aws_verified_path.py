#!/usr/bin/env python3
"""AWS verified path preflight and evidence helper.

The default mode is intentionally non-mutating: it runs local checks, probes
AWS identity when the AWS CLI is available and writes sanitized markdown
summaries. It does not run terraform apply.
"""

from __future__ import annotations

import argparse
import datetime as dt
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_REGION = "us-east-1"

STACKS = [
    ("00-bootstrap", "sandbox apply", "state backend and CI role available"),
    ("10-org", "approval apply", "OU tree stable and account vending opt-in"),
    ("15-departments", "approval apply", "department OU, role and tag baseline visible"),
    ("20-identity", "sandbox apply", "password policy, boundary and account alias visible"),
    ("24-cross-account-access", "sandbox apply", "OIDC/STS trust validates without wildcard trust"),
    ("25-sso", "manual apply", "permission sets and group assignments visible"),
    ("30-network", "sandbox apply", "VPC, subnet and flow log baseline visible"),
    ("35-connectivity", "approval apply", "TGW route isolation matches the expected matrix"),
    ("40-security", "canary OU apply", "SCP and Tag Policy attached only to canary OU"),
    ("45-compliance", "delegated apply", "Config, Security Hub and GuardDuty enabled"),
    ("50-logging", "approval apply", "organization trail writes to log archive"),
    ("55-delegation", "approval apply", "delegated admin service principals are exact"),
    ("60-finops", "sandbox apply", "budget, anomaly detection and CUR are visible"),
    ("70-workload-onboarding", "sandbox apply", "workload handoff output is ready"),
]

REDACTIONS = [
    (re.compile(r"\x1b\[[0-9;]*m"), ""),
    (re.compile(r"\b\d{12}\b"), "123456789012"),
    (re.compile(r"\bo-[a-z0-9]{10,32}\b"), "o-example"),
    (re.compile(r"arn:aws:[^\s\"']+"), "arn:aws:REDACTED"),
    (re.compile(r"[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}"), "team@example.com"),
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run AWS verified path preflight checks.")
    parser.add_argument(
        "--date",
        default=dt.date.today().isoformat(),
        help="Evidence date directory in YYYY-MM-DD format.",
    )
    parser.add_argument(
        "--region",
        default=os.environ.get("AWS_REGION") or os.environ.get("AWS_DEFAULT_REGION") or DEFAULT_REGION,
        help="AWS region used for CLI probes.",
    )
    parser.add_argument(
        "--skip-static",
        action="store_true",
        help="Skip local static checks and only probe tool/cloud readiness.",
    )
    parser.add_argument(
        "--write-stack-placeholders",
        action="store_true",
        help="Write one not-run summary per AWS live stack.",
    )
    return parser.parse_args()


def redact(text: str) -> str:
    redacted = text
    for pattern, replacement in REDACTIONS:
        redacted = pattern.sub(replacement, redacted)
    return redacted


def run_command(args: list[str], timeout: int = 120) -> tuple[int, str]:
    try:
        result = subprocess.run(
            args,
            cwd=ROOT,
            check=False,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=timeout,
        )
    except FileNotFoundError:
        return 127, f"{args[0]} not found"
    except subprocess.TimeoutExpired as exc:
        output = exc.stdout or ""
        return 124, f"command timed out after {timeout}s\n{output}"
    return result.returncode, redact(result.stdout.strip())


def status_word(code: int) -> str:
    if code == 0:
        return "pass"
    if code == 127:
        return "missing"
    if code == 124:
        return "timeout"
    return "fail"


def write_file(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def check_aws(region: str) -> list[tuple[str, str, str]]:
    checks: list[tuple[str, str, str]] = []
    aws_path = shutil.which("aws")
    if not aws_path:
        checks.append(("aws cli", "missing", "aws CLI not found on PATH"))
        checks.append(("aws sts get-caller-identity", "not-run", "requires aws CLI and short-lived credentials"))
        checks.append(("aws organizations describe-organization", "not-run", "requires aws CLI and management/delegated credentials"))
        return checks

    code, output = run_command(["aws", "--version"])
    checks.append(("aws cli", status_word(code), output))

    code, output = run_command(["aws", "sts", "get-caller-identity", "--region", region])
    checks.append(("aws sts get-caller-identity", status_word(code), output))

    if code == 0:
        org_code, org_output = run_command(["aws", "organizations", "describe-organization", "--region", region])
        checks.append(("aws organizations describe-organization", status_word(org_code), org_output))
    else:
        checks.append(("aws organizations describe-organization", "not-run", "STS identity probe did not pass"))
    return checks


def local_checks(skip_static: bool) -> list[tuple[str, str, str, bool]]:
    tool_commands = [
        ("terraform version", ["terraform", "version"], True),
        ("conftest version", ["conftest", "--version"], True),
    ]
    if not skip_static:
        tool_commands.extend(
            [
                ("static release gate", ["python3", "tools/static_release_gate.py"], True),
                ("terraform fmt", ["terraform", "fmt", "-check", "-recursive"], True),
                ("aws conftest verify", ["conftest", "verify", "--policy", "multi-cloud/aws/policies"], True),
                ("alicloud conftest verify", ["conftest", "verify", "--policy", "multi-cloud/alicloud/policies"], True),
                ("checkov terraform scan", ["checkov", "-d", "multi-cloud", "--config-file", ".checkov.yaml", "--framework", "terraform", "--quiet", "--compact"], False),
                ("tflint recursive scan", ["tflint", "--recursive", "--format", "compact"], False),
            ]
        )
    typed_checks: list[tuple[str, str, str, bool]] = []
    for name, command, required in tool_commands:
        code, output = run_command(command, timeout=300)
        status = status_word(code)
        if not required and status == "missing":
            status = "missing-optional"
        typed_checks.append((name, status, output, required))
    return typed_checks


def markdown_table(rows: list[tuple[str, str, str] | tuple[str, str, str, bool]]) -> str:
    lines = ["| Check | Status | Sanitized output |", "|---|---|---|"]
    for row in rows:
        name, status, output = row[:3]
        one_line = output.replace("\n", "<br>")
        if len(one_line) > 600:
            one_line = one_line[:597] + "..."
        lines.append(f"| `{name}` | `{status}` | {one_line or '-'} |")
    return "\n".join(lines)


def write_preflight(date: str, region: str, local: list[tuple[str, str, str, bool]], aws: list[tuple[str, str, str]]) -> Path:
    out = ROOT / "docs/demo/aws-apply-evidence" / date / "preflight-summary.md"
    blocked_reasons = [f"{name}: {detail}" for name, status, detail in aws if status in {"missing", "fail", "not-run"}]
    conclusion = "ready-for-sandbox-plan" if not blocked_reasons else "blocked-before-sandbox-apply"
    content = f"""# AWS Verified Path Preflight Summary

Date: `{date}`
Region: `{region}`
Conclusion: `{conclusion}`

This report is generated by `tools/aws_verified_path.py`. It is safe to commit only after reviewing the sanitized output.

## Local Checks

{markdown_table(local)}

## AWS Readiness

{markdown_table(aws)}

## Apply Decision

No Terraform apply was executed by this helper. A real AWS sandbox apply requires:

- AWS CLI installed.
- Short-lived IAM Identity Center or OIDC/STS credentials.
- Confirmed sandbox Organization scope.
- Manual approval for Organizations, SCP, delegated admin, logging retention and account vending changes.

## Blockers

"""
    if blocked_reasons:
        for reason in blocked_reasons:
            content += f"- {reason}\n"
    else:
        content += "- None from preflight. Continue with `docs/runbooks/aws-apply-order.md`.\n"
    write_file(out, content)
    return out


def write_stack_placeholders(date: str) -> list[Path]:
    paths: list[Path] = []
    for stack, apply_type, success in STACKS:
        path = ROOT / "docs/demo/aws-apply-evidence" / date / f"{stack}-summary.md"
        content = f"""# {stack} Evidence Summary

Stack: `multi-cloud/aws/live/{stack}`
Apply type: `{apply_type}`
Current status: `not-run`

## Expected Success Signal

{success}.

## Evidence Required

- Sanitized Terraform plan or apply summary.
- Terraform output key and resource type summary.
- Policy check summary.
- AWS CLI/API status summary.
- Rollback decision and result.

## Sensitive Data Handling

Do not include real account IDs, ARNs, bucket names, emails, source IPs, identity provider IDs, Terraform state or raw plan files.
"""
        write_file(path, content)
        paths.append(path)
    return paths


def main() -> int:
    args = parse_args()
    local = local_checks(args.skip_static)
    aws = check_aws(args.region)
    preflight = write_preflight(args.date, args.region, local, aws)
    placeholders = write_stack_placeholders(args.date) if args.write_stack_placeholders else []

    print(f"wrote {preflight.relative_to(ROOT)}")
    for path in placeholders:
        print(f"wrote {path.relative_to(ROOT)}")

    failed_local = [name for name, status, _, required in local if required and status not in {"pass"}]
    if failed_local:
        print("local checks failed: " + ", ".join(failed_local), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
