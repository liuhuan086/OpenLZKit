# live/25-sso (Tencent Cloud)

Human access (FP-5): CAM user groups (`platform-admins`, `security-auditors`)
with policy attachments. People join groups via SSO/membership; groups receive
policies, not users. Policy ids are environment-supplied.

## State

```bash
terraform init -backend-config="bucket=lz-tfstate-1250000000" -backend-config="region=ap-guangzhou"
```

## Workflow

```bash
terraform validate
terraform plan -var 'auditor_policy_ids=[12345]'
# apply after PR review + approval
```
