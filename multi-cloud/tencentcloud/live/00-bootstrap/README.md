# live/00-bootstrap (Tencent Cloud)

The one-time foundation every later stack depends on. Runs with **local state**,
then migrates its own state into the COS bucket it creates.

## What it creates

- **COS state bucket** — versioned, AES256-encrypted, private ACL.
- **CI/CD plan CAM role** — assumed via STS from the management account (no
  long-lived SecretKey).

CloudAudit is set up in `50-logging` (it needs a CLS/COS storage target).

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `region` | `string` | `ap-guangzhou` | Region for the COS bucket. |
| `name_prefix` | `string` | `lz-` | Prefix on CAM resource names. |
| `state_bucket_name` | `string` | — | COS bucket name (with APPID suffix). |
| `management_uin` | `string` | — | Root UIN allowed to assume the CI role. |
| `tags` | `map(string)` | `{}` | Bucket tags. |

## Run

```bash
terraform init                 # local state
terraform validate             # static, no account
terraform apply \
  -var state_bucket_name=lz-tfstate-1250000000 \
  -var management_uin=100000000001

# then migrate state into the new bucket (COS backend)
terraform init -migrate-state \
  -backend-config="bucket=lz-tfstate-1250000000" \
  -backend-config="region=ap-guangzhou" \
  -backend-config="prefix=tencentcloud/00-bootstrap"
```

## Security notes

- CI assumes a role via STS — no long-lived SecretKey is created or stored.
- Scope the role's trust to the smallest principal; tighten with conditions for production.
- The state bucket is private, versioned and encrypted.
