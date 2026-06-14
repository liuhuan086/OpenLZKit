# Module: tencentcloud/identity

Creates least-privilege **CAM custom policies and roles** with policy attachments.
Roles are assumed via STS; long-lived sub-users are avoided.

## Responsibilities

- Define custom CAM policies (least-privilege documents).
- Create CAM roles (assume-role trust) and attach custom policies.

It does **not**: create CAM users/groups (see `modules/identity-groups`) or org
manage policies (see `modules/control-policies`).

## Usage

```hcl
module "identity" {
  source = "../../modules/identity"

  custom_policies = {
    readonly = { document = jsonencode({ version = "2.0", statement = [{ effect = "allow", action = ["cam:List*"], resource = ["*"] }] }) }
  }
  roles = {
    auditor = {
      custom_policy_keys = ["readonly"]
      document           = jsonencode({ version = "2.0", statement = [{ effect = "allow", action = ["name/sts:AssumeRole"], principal = { qcs = ["qcs::cam::uin/100000000001:root"] } }] })
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on policy/role names. |
| `custom_policies` | `map(object)` | `{}` | Custom CAM policies (document JSON). |
| `roles` | `map(object)` | `{}` | Roles (trust document, custom_policy_keys). |

## Outputs

| Name | Description |
|---|---|
| `policy_ids` | Map of policy key to id. |
| `role_ids` | Map of role key to id. |

## Security notes

- Roles are assumed via STS — no long-lived SecretKey.
- Keep policy documents least-privilege; scope role trust to the smallest principal.

Validated via [live/20-identity](../../live/20-identity); see [../../tests](../../tests).
