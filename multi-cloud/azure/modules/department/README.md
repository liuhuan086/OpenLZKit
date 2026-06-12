# Module: azure/department

The **business-department** composition: for each department, a dedicated
management group plus an optional admin RBAC scope and budget. Departments sit
under a parent management group (typically Landing Zones) and inherit its policy
guardrails.

## Responsibilities

- Create a management group per department.
- Optionally assign a department-admin role (Entra group preferred), scoped to that group only.
- Optionally create a department budget for cost attribution.

It does **not**: define custom roles (see `modules/identity`) or org-wide policy
(see `modules/policy-guardrails`) — departments inherit those.

## Usage

```hcl
module "departments" {
  source                     = "../../modules/department"
  parent_management_group_id = module.org.management_group_ids["landingzones"]

  departments = {
    engineering = {
      display_name       = "Engineering"
      admin_principal_id = "<entra-group-object-id>"
      budget_amount      = 5000
      budget_start_date  = "2026-01-01T00:00:00Z"
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on department MG names. |
| `parent_management_group_id` | `string` | — | Parent MG resource id. |
| `departments` | `map(object)` | — | Per-department display name, admin principal/role, budget. |

## Outputs

| Name | Description |
|---|---|
| `management_group_ids` | Map of department key to MG id. |
| `admin_role_assignment_ids` | Map of department key to admin assignment id. |

## Security notes

- Department admin RBAC is scoped to the department management group only — no cross-department access.
- Departments inherit organization deny guardrails from the parent group.

Validated via [live/15-departments](../../live/15-departments); see [../../tests](../../tests).
