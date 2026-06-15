# Expected Controls

| Area | Control | Evidence |
|---|---|---|
| Identity | Humans use IAM Identity Center groups, not IAM users | permission set / assignment summary |
| CI/CD | GitHub Actions uses OIDC AssumeRole | IAM trust policy, `iam_trust.rego` |
| Object storage | Public S3 access is blocked | plan JSON, Config rule, `s3_state.rego` |
| Terraform state | State bucket is encrypted, versioned and private | plan JSON, Checkov, `s3_state.rego` |
| Tags | `managed_by`, `owner`, `cost_center`, `environment` are present | `tags.rego`, plan JSON |
| Network | prod/dev/sandbox routes stay isolated | TGW route table matrix |
| Logging | CloudTrail organization trail writes to log archive | CloudTrail summary, S3 retention |
| FinOps | Budgets and cost ownership exist per account/workload | budget summary, tag policy |
| Compliance | Config/Security Hub/GuardDuty are enabled where supported | service status summary |
