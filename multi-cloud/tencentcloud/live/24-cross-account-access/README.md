# live/24-cross-account-access (Tencent Cloud)

Cross-account access (FP-4): a read-only **security-audit** CAM role in this
account that the security account may assume via STS. Attached policies are
environment-supplied via `audit_policy_ids` (empty by default).

## State

```bash
terraform init -backend-config="bucket=lz-tfstate-1250000000" -backend-config="region=ap-guangzhou"
```

## Workflow

```bash
terraform validate
terraform plan -var security_account_uin=<security-account-uin>
# apply after PR review + approval
```
