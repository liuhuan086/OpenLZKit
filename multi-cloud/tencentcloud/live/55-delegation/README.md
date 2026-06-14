# live/55-delegation (Tencent Cloud)

Delegated management & sharing (FP-8): an organization share unit for delegating
shared network resources, plus optional least-privilege member auth-policy
delegations (empty by default).

## State

```bash
terraform init -backend-config="bucket=lz-tfstate-1250000000" -backend-config="region=ap-guangzhou"
```

## Workflow

```bash
terraform validate
terraform plan
# apply after PR review + approval; delegate only least-privilege policies
```
