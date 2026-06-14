# Module: tencentcloud/cross-account-access

**Cross-account access** (FP-4): CAM roles with cross-account trust (assumed via
STS) and least-privilege policy attachments.

## Responsibilities

- Create CAM roles trusting source account UINs.
- Attach CAM policies (preset/custom) to those roles.

It does **not**: create policies (see `modules/identity`) or share resources (see
`modules/delegation` / org share units).

## Usage

```hcl
module "cross_account" {
  source = "../../modules/cross-account-access"

  access_roles = {
    security-audit = {
      name         = "security-audit"
      trusted_uins = ["100000000002"]
      policy_ids   = [12345]
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on role names. |
| `access_roles` | `map(object)` | `{}` | Roles (trusted_uins, policy_ids, session_duration). |

## Outputs

| Name | Description |
|---|---|
| `role_ids` | Map of role key to CAM role id. |

## Security notes

- Roles are assumed via STS — no long-lived SecretKey.
- Scope `trusted_uins` to the smallest set; attach least-privilege policies (avoid full-access presets).

Validated via [live/24-cross-account-access](../../live/24-cross-account-access); see [../../tests](../../tests).
