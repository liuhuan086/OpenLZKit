# AWS Org (basic) Example

Validates the [`org`](../../modules/org) module: an AWS Organizations OU
hierarchy (Security / Infrastructure / Workloads / Sandbox) with a consistent
name prefix and tags. No real accounts are created here — account vending lives
in [`account-factory`](../account-factory).

## Run static checks

```bash
terraform init -backend=false
terraform validate
```

`plan`/`apply` require management-account credentials (prefer short-lived STS)
and are normally driven from `live/10-org`.
