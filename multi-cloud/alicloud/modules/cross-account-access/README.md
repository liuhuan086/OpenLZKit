# Module: alicloud/cross-account-access

Creates standard Alibaba Cloud cross-account access building blocks.

## Responsibilities

- Create target-account RAM roles trusted by explicit source-account principals.
- Attach Alibaba system policies to those roles.
- Preserve trust-policy conditions when the caller needs external-id, source-ip
  or other STS restrictions.
- Create Resource Share definitions for shared infrastructure resources.

It does **not**:

- Create source or target accounts.
- Create custom RAM policies.
- Configure CloudSSO users or groups.
- Replace organization-level deny guardrails.

## Preconditions

- Deploy RAM roles in the target account where access is needed.
- Use short-lived STS or CI/OIDC credentials for Terraform.
- Resource Share targets and shared resources already exist.

## Usage

```hcl
module "cross_account_access" {
  source = "../../modules/cross-account-access"

  name_prefix = "lz-"

  access_roles = {
    security_audit = {
      role_name          = "security-audit"
      trusted_principals = ["acs:ram::1111222233334444:root"]
      system_policies    = ["SecurityAudit"]
      condition = {
        StringEquals = {
          "sts:ExternalId" = "security-audit"
        }
      }
    }
  }

  resource_shares = {
    shared_network = {
      name            = "shared-network"
      targets         = ["1111222233334444"]
      resource_arns   = ["acs:vpc:cn-hangzhou:5555666677778888:vpc/vpc-example"]
      permission_names = ["AliyunRSDefaultPermissionVSwitch"]
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `""` | Prefix applied to role and resource-share names. |
| `max_session_duration` | `number` | `3600` | Cross-account role session duration. |
| `access_roles` | `map(object)` | `{}` | RAM roles to create in target accounts. |
| `resource_shares` | `map(object)` | `{}` | Resource Share definitions. |
| `common_tags` | `map(string)` | `{ managed_by = "terraform" }` | Tags merged onto roles and shares. |

## Outputs

| Name | Description |
|---|---|
| `role_names` | Cross-account role names by key. |
| `role_arns` | Cross-account role ARNs by key. |
| `resource_share_ids` | Resource Share ids by key. |

## Security notes

- Prefer specific source principals over `root`; use `root` only for bootstrap
  demos and then tighten.
- Add `condition` blocks for CI/CD and third-party access.
- Keep role permissions read-only unless the workflow requires writes.
- Do not enable `allow_external_targets` unless sharing outside the Resource
  Directory is intentional and approved.

## Testing

Static checks (no cloud account required):

```bash
terraform -chdir=examples/cross-account-access fmt -check -recursive
terraform -chdir=examples/cross-account-access init -backend=false
terraform -chdir=examples/cross-account-access validate
```

`plan`/`apply` require target-account RAM permissions and, for shares,
Resource Share permissions.
