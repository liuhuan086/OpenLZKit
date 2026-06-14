# Module: tencentcloud/delegation

**Delegated management & resource sharing** (FP-8): organization share units (and
shared resources) plus least-privilege member auth-policy delegations.

## Responsibilities

- Create organization share units and share resources into them.
- Delegate management to a member sub-account via an auth policy (least-privilege).

It does **not**: create the delegated policies (see `modules/identity` /
`control-policies`) or member accounts (see `account-factory`).

## Usage

```hcl
module "delegation" {
  source = "../../modules/delegation"

  share_units = {
    network-sharing = { name = "network-sharing", area = "ap-guangzhou" }
  }
  member_delegations = {
    security-admin = { org_sub_account_uin = "100000000003", policy_id = 12345 }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on share unit names. |
| `share_units` | `map(object)` | `{}` | Share units (name, area). |
| `shared_resources` | `map(object)` | `{}` | Resources shared into a unit. |
| `member_delegations` | `map(object)` | `{}` | Member auth-policy delegations. |

## Outputs

| Name | Description |
|---|---|
| `share_unit_ids` | Map of share unit key to id. |

## Security notes

- Delegate only least-privilege policies — never full-access — to member sub-accounts.
- Share specific resources into a unit rather than granting broad cross-account access.

Validated via [live/55-delegation](../../live/55-delegation); see [../../tests](../../tests).
