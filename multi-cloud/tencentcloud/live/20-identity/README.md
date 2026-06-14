# live/20-identity (Tencent Cloud)

Identity layer: a least-privilege `security-auditor` CAM role (read-only custom
policy) assumed from the management account. Long-lived sub-users are avoided.

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
