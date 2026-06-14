# Module: tencentcloud/identity-groups

**Human access** (FP-5, the CloudSSO equivalent): CAM user groups granted policies.
People join groups via SSO/membership; **groups, not users**, receive policies.

## Responsibilities

- Create CAM user groups (access personas).
- Attach CAM policies to those groups.

It does **not**: create CAM users, define policies (see `modules/identity`), or
configure the SSO identity provider.

## Usage

```hcl
module "groups" {
  source = "../../modules/identity-groups"

  groups = {
    security-auditors = { name = "security-auditors", policy_ids = [12345] }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on group names. |
| `groups` | `map(object)` | `{}` | Groups (name, remark, policy_ids). |

## Outputs

| Name | Description |
|---|---|
| `group_ids` | Map of group key to CAM group id. |

## Security notes

- Attach policies to groups, never individual users.
- Use SSO for human access; avoid long-lived sub-user SecretKeys.

Validated via [live/25-sso](../../live/25-sso); see [../../tests](../../tests).
