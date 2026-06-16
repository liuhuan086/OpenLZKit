# AWS Apply Evidence

This directory documents the expected shape of sanitized AWS sandbox evidence. It is intentionally empty of real cloud output in `v0.1.0`.

Do not commit raw Terraform plans, state files, CloudTrail events, account IDs, ARNs, bucket names, source IPs, user names, identity provider IDs or non-example emails.

## Expected Structure

```text
docs/demo/aws-apply-evidence/
├── README.md
└── YYYY-MM-DD/
    ├── 00-bootstrap-summary.md
    ├── 10-org-summary.md
    ├── 20-identity-summary.md
    ├── conftest-summary.md
    ├── cloudtrail-summary.md
    ├── cost-summary.md
    └── rollback-summary.md
```

## Minimum Fields Per Stack

| Field | Requirement |
|---|---|
| Scope | Sandbox organization/account alias only; no real IDs |
| Apply type | `sandbox-applied`, `dry-run-only`, `manual-check-only` or `not-run` |
| Inputs | Only file names and variable keys; no secret or unique values |
| Plan summary | Resource type counts and high-level actions |
| Policy checks | Checkov/TFLint/Conftest pass/fail summary |
| Runtime evidence | AWS service status summary, with identifiers redacted |
| Rollback | Destroy/detach/manual-retain decision and result |

## Redaction Rules

- Replace 12-digit account IDs with `123456789012`.
- Replace organization IDs with `o-example`.
- Replace ARNs with role or resource type summaries.
- Replace bucket names, KMS key IDs and CloudTrail trail names with logical names.
- Replace personal emails with `team-name@example.com`.
- Keep dates, regions, service names, policy names and resource types when they are not sensitive.
