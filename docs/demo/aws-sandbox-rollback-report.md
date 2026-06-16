# AWS Sandbox Rollback Report

> This is a rollback evidence template for the AWS verified path. It records what was destroyed, detached, retained or manually cleaned up after a sandbox apply. It must never include real account IDs, ARNs, bucket names, source IPs, user names or non-example emails.

## Scope

| Item | Example | Notes |
|---|---|---|
| Date | `2026-06-16` | Use the actual rollback date |
| Organization | `o-example` | Redacted organization identifier |
| Management account | `123456789012` | Redacted account identifier |
| Region | `us-east-1` | Region is usually safe to keep |
| Operator | `platform-team@example.com` | Use team mailbox or role name only |
| Evidence location | `docs/demo/aws-apply-evidence/YYYY-MM-DD/rollback-summary.md` | Commit only sanitized summaries |

## Rollback Matrix

| Stack | Applied state | Rollback action | Result | Residual risk |
|---|---|---|---|---|
| `00-bootstrap` | `not-run` | Retain state backend | Not applicable | State resources are dependencies for other stacks |
| `10-org` | `not-run` | Close test accounts or remove OU resources | Not applicable | AWS account closure has a cooldown period |
| `15-departments` | `not-run` | Destroy department OU/role resources | Not applicable | Detach SCP/Tag Policy first if attached |
| `20-identity` | `not-run` | Destroy account-local IAM baseline changes | Not applicable | Preserve break-glass access |
| `24-cross-account-access` | `not-run` | Remove test roles/OIDC provider/RAM shares | Not applicable | Confirm no workload depends on role |
| `25-sso` | `not-run` | Remove test assignments and permission sets | Not applicable | Identity Center assignments may be cached briefly |
| `30-network` | `not-run` | Destroy test VPC resources | Not applicable | Detach endpoints and flow logs first |
| `35-connectivity` | `not-run` | Detach TGW attachments and RAM shares | Not applicable | Route propagation can lag |
| `40-security` | `not-run` | Detach SCP/Tag Policy before deletion | Not applicable | Never test new SCP directly on root |
| `45-compliance` | `not-run` | Disable test delegated services and recorders | Not applicable | Findings may remain for retention window |
| `50-logging` | `not-run` | Retain log archive or delete only test streams | Not applicable | Object Lock can prevent deletion |
| `55-delegation` | `not-run` | Deregister delegated admins and remove RAM shares | Not applicable | Service-linked roles can remain |
| `60-finops` | `not-run` | Delete test budgets/CUR/anomaly monitors | Not applicable | Billing exports can lag |
| `70-workload-onboarding` | `not-run` | Remove workload access role and handoff metadata | Not applicable | Confirm CI can no longer assume role |

## Evidence Checklist

- `terraform destroy` or manual detach command summary, with identifiers redacted.
- AWS CLI/API status summary after rollback.
- CloudTrail event type and time window summary.
- Remaining resources and retention reason.
- Follow-up action owner and due date.

## Current `v0.1.0` Status

No real AWS sandbox rollback has been executed or claimed for `v0.1.0`. The matrix above is a template for the future `v0.2.0` AWS Verified Sandbox Release.
