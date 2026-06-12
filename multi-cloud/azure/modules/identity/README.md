# Module: azure/identity

Creates least-privilege **custom RBAC role definitions** and **role assignments**.
People reach roles via Entra ID groups (group principals preferred over users).

## Responsibilities

- Define custom RBAC roles (least-privilege `actions`/`not_actions`).
- Assign built-in or custom roles to principals at a given scope.

It does **not**: create Entra groups/users (supply their object ids), or manage
PIM eligibility.

## Usage

```hcl
module "identity" {
  source = "../../modules/identity"

  custom_roles = {
    security-auditor = {
      scope             = var.root_scope_id
      assignable_scopes = [var.root_scope_id]
      actions           = ["*/read"]
    }
  }

  role_assignments = {
    auditors = {
      scope           = var.root_scope_id
      principal_id    = "<entra-group-object-id>"
      principal_type  = "Group"
      custom_role_key = "security-auditor"
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on custom role names. |
| `custom_roles` | `map(object)` | `{}` | Custom role definitions (scope, assignable_scopes, actions). |
| `role_assignments` | `map(object)` | `{}` | Assignments: built-in (`role_definition_name`) or custom (`custom_role_key`). |

## Outputs

| Name | Description |
|---|---|
| `custom_role_ids` | Map of custom role key to role definition id. |
| `role_assignment_ids` | Map of assignment key to id. |

## Security notes

- Prefer Entra **group** principals; avoid per-user assignments.
- Keep custom-role `actions` minimal; deny RBAC self-management via `not_actions`.

Validated via [live/20-identity](../../live/20-identity); see [../../tests](../../tests).
