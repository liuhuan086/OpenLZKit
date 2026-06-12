# AWS Org Policies Example

Validates the [`org-policies`](../../modules/org-policies) module: organization
guardrails as Service Control Policies (SCP) and Tag Policies — e.g. deny
disabling audit/detective controls, require tags. Policies are created and
attached to OUs/root.

## Run static checks

```bash
terraform init -backend=false
terraform validate
```

`plan`/`apply` require Organizations management-account credentials (prefer
short-lived STS) and are normally driven from `live/40-security`. SCPs change
the permission boundary of every account in scope — roll out by OU and review
carefully.
