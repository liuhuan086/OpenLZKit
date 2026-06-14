# live/60-finops (Tencent Cloud)

Cost governance: enable the FinOps tag set (`owner`, `cost_center`, `env`,
`project`) for cost allocation. Budgets are opt-in via the module's `budgets`
input (Tencent budgets require several bill/plan/period fields).

## State

```bash
terraform init -backend-config="bucket=lz-tfstate-1250000000" -backend-config="region=ap-guangzhou"
```

## Workflow

```bash
terraform validate
terraform plan
# apply after PR review + approval
```
