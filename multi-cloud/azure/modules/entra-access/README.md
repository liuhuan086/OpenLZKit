# Module: azure/entra-access

**Human access** (FP-5, the Azure SSO equivalent): Entra ID security groups
granted RBAC at management group / subscription scope. People are added to groups
via the IdP; **groups, not users**, receive roles.

## Responsibilities

- Create Entra ID security groups (access personas).
- Assign built-in/custom roles to those groups at a scope.

It does **not**: manage group membership (IdP/HR sync), configure PIM eligibility,
or create custom role definitions (see `modules/identity`).

## Usage

```hcl
module "entra_access" {
  source = "../../modules/entra-access"

  groups = {
    security-auditors = { display_name = "Security Auditors" }
  }
  role_assignments = {
    security-auditors = { group_key = "security-auditors", scope = var.root_management_group_id, role_definition_name = "Reader" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on group display names. |
| `groups` | `map(object)` | `{}` | Entra security groups (display_name, description). |
| `role_assignments` | `map(object)` | `{}` | Group → role at scope. |

## Outputs

| Name | Description |
|---|---|
| `group_object_ids` | Map of group key to Entra object id. |
| `role_assignment_ids` | Map of assignment key to id. |

## Security notes

- Assign roles to groups, never individual users; gate high-privilege roles behind PIM.
- Prefer the highest appropriate scope (management group) so access is consistent and auditable.

Validated via [live/25-sso](../../live/25-sso); see [../../tests](../../tests).
