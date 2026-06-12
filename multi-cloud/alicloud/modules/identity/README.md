# Module: alicloud/identity

Creates the Landing Zone's **assumable RAM roles**. People reach these via
SSO/federation and machines via OIDC — long-lived RAM users are deliberately
**not** modeled (least-privilege, short-lived credentials).

## Responsibilities

- Create RAM roles from a declarative map, each with a trust policy.
- Attach Alibaba **system** policies to each role.

It does **not**: create RAM users or AccessKeys, configure CloudSSO directory
sync, or manage workload service roles.

## Usage

```hcl
module "identity" {
  source      = "../../modules/identity"
  name_prefix = "lz-"

  roles = {
    security-auditor = {
      description        = "Read-only security & audit."
      trusted_principals = ["acs:ram::123456789012:root"]
      system_policies    = ["ReadOnlyAccess", "AliyunActionTrailReadOnlyAccess"]
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on every role name. |
| `max_session_duration` | `number` | `3600` | Assume-role session seconds. |
| `roles` | `map(object)` | — | `trusted_principals` (RAM ARNs allowed to assume) + `system_policies` (system policy names) + `description`. |

## Outputs

| Name | Description |
|---|---|
| `role_names` | Map of role key to RAM role name. |
| `role_arns` | Map of role key to RAM role ARN. |

## Security notes

- No RAM users / AccessKeys — assume-role only.
- Scope `trusted_principals` as tightly as possible (specific users/roles over account root).
- Production-changing roles should require approval and JIT elevation.

Validated via [live/20-identity](../../live/20-identity); see [../../tests](../../tests).
