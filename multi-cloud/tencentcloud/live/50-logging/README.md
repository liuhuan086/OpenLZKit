# live/50-logging (Tencent Cloud)

Central audit: a CLS logset/topic and an organization-wide CloudAudit track
delivering management (write) events to it.

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
