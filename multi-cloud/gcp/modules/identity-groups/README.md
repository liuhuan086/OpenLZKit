# Module: gcp/identity-groups

**Human access** (FP-5, the GCP SSO equivalent): Cloud Identity security groups
granted IAM at folder/project scope. People are added to groups via the IdP;
**groups, not users**, receive roles.

## Responsibilities

- Create Cloud Identity security groups (access personas).
- Bind built-in/custom roles to those groups at folder or project scope.

It does **not**: manage group membership (IdP/HR sync) or create custom roles
(see `modules/identity`).

## Usage

```hcl
module "groups" {
  source      = "../../modules/identity-groups"
  customer_id = "customers/C0xxxxxxx"

  groups = {
    security-auditors = { email = "lz-security-auditors@example.com" }
  }
  folder_bindings = {
    security-auditors = { group_key = "security-auditors", folder = "folders/111", role = "roles/viewer" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `customer_id` | `string` | — | Cloud Identity customer parent. |
| `groups` | `map(object)` | `{}` | Security groups (email, display_name). |
| `folder_bindings` | `map(object)` | `{}` | Group → role at folder scope. |
| `project_bindings` | `map(object)` | `{}` | Group → role at project scope. |

## Outputs

| Name | Description |
|---|---|
| `group_ids` | Map of group key to resource id. |
| `group_emails` | Map of group key to email. |

## Security notes

- Bind roles to groups, never individual users.
- Prefer the highest appropriate scope (org/folder) so access is consistent and auditable.

Validated via [live/25-sso](../../live/25-sso); see [../../tests](../../tests).
