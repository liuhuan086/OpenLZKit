# live/70-workload-onboarding (Tencent Cloud)

Template for onboarding a new workload: a workload CAM role tagged with the
standard FinOps tag set. Copy the module block per workload/environment.

## State

```bash
terraform init -backend-config="bucket=lz-tfstate-1250000000" -backend-config="region=ap-guangzhou"
```

## Workflow

```bash
terraform validate
terraform plan -var management_uin=<root-uin>
# apply after PR review + approval
```
