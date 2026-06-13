# Module: gcp/department

The **business-department** composition: for each department, a dedicated folder
plus an optional admin IAM binding and a folder-scoped budget. Departments sit
under a parent folder (typically Workloads) and inherit its org policies.

## Responsibilities

- Create a folder per department.
- Optionally bind a department-admin role (Cloud Identity group preferred), scoped to that folder.
- Optionally create a department budget scoped to the folder (resource ancestors).

It does **not**: define custom roles (see `modules/identity`) or org-wide policy
(see `modules/org-policies`) — departments inherit those.

## Usage

```hcl
module "departments" {
  source          = "../../modules/department"
  parent          = module.org.folder_names["workloads"]
  billing_account = "0X0X0X-0X0X0X-0X0X0X"

  departments = {
    engineering = {
      display_name = "Engineering"
      admin_member = "group:eng-admins@example.com"
      budget_units = 5000
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on department folder names. |
| `parent` | `string` | — | Parent folder/org id. |
| `billing_account` | `string` | `null` | Billing account for department budgets. |
| `departments` | `map(object)` | — | Per-department display name, admin, budget. |

## Outputs

| Name | Description |
|---|---|
| `folder_names` | Map of department key to folder resource name. |
| `folder_ids` | Map of department key to numeric folder id. |

## Security notes

- Department admin IAM is scoped to the department folder only — no cross-department access.
- Departments inherit organization deny guardrails (org policy) from the parent.

Validated via [live/15-departments](../../live/15-departments); see [../../tests](../../tests).
