# Example: alicloud/org basic

Minimal Landing Zone folder hierarchy built with the [`org`](../../modules/org)
module, mirroring the account structure in
[docs/design/06](../../../../docs/design/06-alicloud-landing-zone-design.md).

Member accounts are intentionally omitted (billing impact); this example is safe
to `init -backend=false` and `validate` without a cloud account.

## Run static checks

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

## Plan against a real account (optional)

Requires RAM credentials with Resource Directory permissions on the management account:

```bash
export ALICLOUD_ACCESS_KEY=...      # prefer short-lived STS credentials
export ALICLOUD_SECRET_KEY=...
export ALICLOUD_SECURITY_TOKEN=...
terraform plan -var region=cn-hangzhou
```
