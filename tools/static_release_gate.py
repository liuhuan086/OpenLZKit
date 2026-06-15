#!/usr/bin/env python3
"""Static release checks for OpenLZKit documentation and demo artifacts.

The gate is intentionally dependency-free so it can run locally and in CI
without cloud credentials, package installs or network access.
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

MARKDOWN_LINK = re.compile(r"(?<!!)\[[^\]]+\]\(([^)]+)\)")
TODO_MARKER = re.compile(r"\b(TODO|TBD)\b", re.IGNORECASE)
SENSITIVE_PATTERNS = [
    re.compile(r"AKIA[0-9A-Z]{16}"),
    re.compile(r"ASIA[0-9A-Z]{16}"),
    re.compile(r"-----BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY-----"),
    re.compile(r"(?i)\b(access_key|secret_key|client_secret|tenant_id)\s*[:=]\s*['\"]?[A-Za-z0-9_./+=-]{8,}"),
    re.compile(r"(?i)\bpassword\s*[:=]\s*['\"]?[^'\"\s]{8,}"),
    re.compile(r"\bsubscription_id\s*:\s*[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b"),
]

REQUIRED_REQUEST_KEYS = {
    "request/aws-account-request.yaml": {"schema_version", "cloud", "request_type", "account_name", "email", "owner", "environment", "ou", "network_tier", "budget_limit_usd"},
    "request/alicloud-account-request.yaml": {"schema_version", "cloud", "request_type", "account_name", "email", "owner", "environment", "resource_directory_folder", "network_tier", "budget_limit_usd"},
    "request/azure-subscription-request.yaml": {"schema_version", "cloud", "request_type", "subscription_name", "subscription_id", "owner", "environment", "management_group", "network_tier", "budget_limit_usd"},
    "request/gcp-project-request.yaml": {"schema_version", "cloud", "request_type", "project_id", "project_name", "billing_account", "owner", "environment", "folder", "network_tier", "budget_limit_usd"},
    "request/tencentcloud-account-request.yaml": {"schema_version", "cloud", "request_type", "account_name", "uin", "owner", "environment", "organization_node", "network_tier", "budget_limit_usd"},
}

REQUIRED_TAG_KEYS = {"managed_by", "owner", "cost_center", "environment"}

REQUIRED_DEMO_FILES = [
    "examples/demo/README.md",
    "examples/demo/aws-small-company/org-request.yaml",
    "examples/demo/aws-small-company/account-request.yaml",
    "examples/demo/aws-small-company/workload-request.yaml",
    "examples/demo/aws-small-company/expected-ou-tree.md",
    "examples/demo/aws-small-company/expected-network.md",
    "examples/demo/aws-small-company/expected-controls.md",
]

REQUIRED_RELEASE_DOCS = [
    "docs/demo/aws-sandbox-apply-report.md",
    "docs/compliance/control-mapping.md",
    "docs/releases.md",
    "docs/release-notes/v0.1.0.md",
    "docs/runbooks/aws-apply-order.md",
    "docs/runbooks/aws-rollback.md",
    "docs/runbooks/aws-break-glass-access.md",
    "docs/runbooks/aws-drift-detection.md",
    "docs/runbooks/aws-account-vending-failure.md",
    "docs/runbooks/aws-cloudtrail-audit-check.md",
    "docs/runbooks/terraform-state-recovery.md",
    "docs/runbooks/ci-oidc-permission-troubleshooting.md",
]


def tracked_files() -> list[Path]:
    result = subprocess.run(
        ["git", "ls-files"],
        cwd=ROOT,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    )
    return [ROOT / line for line in result.stdout.splitlines() if line]


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def check_required_files(errors: list[str]) -> None:
    for file_name in REQUIRED_DEMO_FILES + REQUIRED_RELEASE_DOCS:
        if not (ROOT / file_name).is_file():
            fail(errors, f"missing required v0.1.0 artifact: {file_name}")


def check_markdown_links(files: list[Path], errors: list[str]) -> None:
    for path in files:
        if path.suffix.lower() != ".md":
            continue
        for line_no, line in enumerate(read_text(path).splitlines(), start=1):
            for match in MARKDOWN_LINK.finditer(line):
                href = match.group(1).strip()
                target = href.split("#", 1)[0]
                if not target or re.match(r"^[a-z][a-z0-9+.-]*:", target, re.IGNORECASE):
                    continue
                if target.startswith("<") and target.endswith(">"):
                    target = target[1:-1]
                resolved = (path.parent / target).resolve()
                try:
                    resolved.relative_to(ROOT)
                except ValueError:
                    fail(errors, f"{rel(path)}:{line_no}: link escapes repository: {href}")
                    continue
                if not resolved.exists():
                    fail(errors, f"{rel(path)}:{line_no}: broken internal link: {href}")


def check_unfinished_markers(files: list[Path], errors: list[str]) -> None:
    allowlist = {
        ("docs/testing-strategy.md", "`TODO` / `TBD`"),
        ("tests/TEST_CASES.md", "`TODO`"),
        ("tests/TEST_CASES.md", "TODO/TBD"),
    }
    for path in files:
        if path.suffix.lower() not in {".md", ".yaml", ".yml", ".tf", ".rego"}:
            continue
        for line_no, line in enumerate(read_text(path).splitlines(), start=1):
            if not TODO_MARKER.search(line):
                continue
            if any(rel(path) == allowed_path and allowed_text in line for allowed_path, allowed_text in allowlist):
                continue
            fail(errors, f"{rel(path)}:{line_no}: unresolved TODO/TBD marker")


def check_sensitive_values(files: list[Path], errors: list[str]) -> None:
    for path in files:
        if path.suffix.lower() in {".png", ".jpg", ".jpeg", ".gif", ".pdf"}:
            continue
        try:
            text = read_text(path)
        except UnicodeDecodeError:
            continue
        for line_no, line in enumerate(text.splitlines(), start=1):
            for pattern in SENSITIVE_PATTERNS:
                if pattern.search(line):
                    fail(errors, f"{rel(path)}:{line_no}: potential sensitive value: {pattern.pattern}")
        for line_no, line in enumerate(text.splitlines(), start=1):
            for email in re.findall(r"[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}", line):
                if not email.endswith("@example.com"):
                    fail(errors, f"{rel(path)}:{line_no}: non-example email address: {email}")


def top_level_keys(path: Path) -> set[str]:
    keys: set[str] = set()
    for raw_line in read_text(path).splitlines():
        line = raw_line.rstrip()
        if not line or line.lstrip().startswith("#"):
            continue
        if line[:1].isspace() or line.startswith("-"):
            continue
        if ":" in line:
            keys.add(line.split(":", 1)[0].strip())
    return keys


def nested_mapping_keys(path: Path, parent: str) -> set[str]:
    keys: set[str] = set()
    in_parent = False
    parent_indent = 0
    for raw_line in read_text(path).splitlines():
        if not raw_line.strip() or raw_line.lstrip().startswith("#"):
            continue
        indent = len(raw_line) - len(raw_line.lstrip(" "))
        stripped = raw_line.strip()
        if indent == 0:
            current = stripped.split(":", 1)[0]
            in_parent = current == parent
            parent_indent = indent
            continue
        if in_parent and indent > parent_indent and ":" in stripped and not stripped.startswith("-"):
            keys.add(stripped.split(":", 1)[0].strip())
    return keys


def scalar_value(path: Path, key: str) -> str | None:
    for raw_line in read_text(path).splitlines():
        if raw_line.startswith(" ") or ":" not in raw_line:
            continue
        found, value = raw_line.split(":", 1)
        if found.strip() == key:
            return value.strip().strip('"').strip("'")
    return None


def check_request_examples(errors: list[str]) -> None:
    for file_name, required in REQUIRED_REQUEST_KEYS.items():
        path = ROOT / file_name
        if not path.is_file():
            fail(errors, f"missing request example: {file_name}")
            continue
        keys = top_level_keys(path)
        missing = sorted(required - keys)
        if missing:
            fail(errors, f"{file_name}: missing required keys: {', '.join(missing)}")
        cloud = scalar_value(path, "cloud")
        expected_cloud = file_name.split("/", 1)[1].split("-", 1)[0]
        if expected_cloud == "tencentcloud":
            expected_cloud = "tencentcloud"
        if cloud != expected_cloud:
            fail(errors, f"{file_name}: cloud must be {expected_cloud}, got {cloud!r}")
        metadata_parent = "labels" if cloud == "gcp" else "tags"
        tag_keys = nested_mapping_keys(path, metadata_parent)
        missing_tags = sorted(REQUIRED_TAG_KEYS - tag_keys)
        if missing_tags:
            fail(errors, f"{file_name}: {metadata_parent} missing: {', '.join(missing_tags)}")


def check_demo_examples(errors: list[str]) -> None:
    org = ROOT / "examples/demo/aws-small-company/org-request.yaml"
    account = ROOT / "examples/demo/aws-small-company/account-request.yaml"
    workload = ROOT / "examples/demo/aws-small-company/workload-request.yaml"
    for path in [org, account, workload]:
        keys = top_level_keys(path)
        for required in {"schema_version", "cloud"}:
            if required not in keys:
                fail(errors, f"{rel(path)}: missing required key: {required}")
        if scalar_value(path, "cloud") != "aws":
            fail(errors, f"{rel(path)}: demo cloud must be aws")
    controls = read_text(ROOT / "examples/demo/aws-small-company/expected-controls.md")
    for control in ["Identity", "CI/CD", "Object storage", "Terraform state", "Tags", "Network", "Logging", "FinOps", "Compliance"]:
        if control not in controls:
            fail(errors, f"examples/demo/aws-small-company/expected-controls.md: missing control area {control}")


def main() -> int:
    errors: list[str] = []
    os.chdir(ROOT)
    files = tracked_files()

    check_required_files(errors)
    check_markdown_links(files, errors)
    check_unfinished_markers(files, errors)
    check_sensitive_values(files, errors)
    check_request_examples(errors)
    check_demo_examples(errors)

    if errors:
        print("Static release gate failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print("Static release gate passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
