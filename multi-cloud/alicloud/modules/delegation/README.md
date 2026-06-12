# Module: alicloud/delegation

Creates Alibaba Cloud organization-level delegated administration and governed
resource sharing.

## Responsibilities

- Register Resource Directory delegated administrators for cloud services.
- Delegate CloudSSO administration to a member account.
- Create Resource Share definitions with targets, resources, resource ARNs and
  permissions.

It does **not**:

- Create delegated member accounts.
- Create the shared resources themselves.
- Create cross-account RAM roles; use `modules/cross-account-access`.

## Usage

```hcl
module "delegation" {
  source = "../../modules/delegation"

  delegated_administrators = {
    config = {
      account_id        = "1234567890123456"
      service_principal = "config.aliyuncs.com"
    }
  }

  cloud_sso_delegate_account_id = "1234567890123456"

  resource_shares = {
    shared_network = {
      name             = "shared-network"
      targets          = ["2345678901234567"]
      resource_arns    = ["acs:vpc:cn-hangzhou:1234567890123456:vswitch/vsw-example"]
      permission_names = ["AliyunRSDefaultPermissionVSwitch"]
    }
  }
}
```

## Security notes

- Delegate only to dedicated security, compliance, network or identity accounts.
- Keep service principals explicit and review them during architecture changes.
- Keep `allow_external_targets = false` unless external sharing is approved.
- Prefer sharing specific resource ARNs/resources over broad account-level access.

## Testing

```bash
terraform -chdir=examples/delegation fmt -check -recursive
terraform -chdir=examples/delegation init -backend=false
terraform -chdir=examples/delegation validate
```
