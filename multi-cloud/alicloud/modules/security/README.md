# Module: alicloud/security

Applies **account-wide RAM guardrails**: a strong password policy and a hardened
security preference (enforced MFA, no user-managed AccessKeys, bounded sessions).

## Responsibilities

- `alicloud_ram_account_password_policy` — length/age/reuse/lockout + required character classes.
- `alicloud_ram_security_preference` — enforce MFA on login, discourage user-managed AccessKeys.

These are singleton, account-wide settings, so this module is applied once on the
management account. It does **not** manage ActionTrail/SLS audit (see `50-logging`)
or per-resource controls (those live with their domain modules / policy-as-code).

## Usage

```hcl
module "security" {
  source = "../../modules/security"
  # secure defaults; override only when justified
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `minimum_password_length` | `number` | `14` | Minimum password length. |
| `max_password_age` | `number` | `90` | Password expiry days (0 = none). |
| `password_reuse_prevention` | `number` | `5` | Disallowed previous passwords. |
| `max_login_attempts` | `number` | `5` | Failed attempts before lockout. |
| `mfa_operation_for_login` | `string` | `"mandatory"` | MFA requirement on login. |
| `allow_user_to_manage_access_keys` | `bool` | `false` | Let users manage own AccessKeys. |
| `login_session_duration` | `number` | `6` | Console session hours. |

Required character classes (lowercase/uppercase/numbers/symbols) are always enabled.

## Outputs

| Name | Description |
|---|---|
| `password_policy_id` | RAM password policy id. |
| `security_preference_id` | RAM security preference id. |

## Security notes

- MFA is enforced and user-managed AccessKeys are off by default — prefer SSO + short-lived credentials.
- Tightening these settings affects all RAM users; coordinate rollout.

Validated via [live/40-security](../../live/40-security); see [../../tests](../../tests).
