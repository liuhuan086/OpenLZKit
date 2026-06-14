# Module: tencentcloud/department

The **business-department** composition: for each department, a dedicated
organization node plus an optional admin CAM role and an optional manage-policy
attachment. Departments sit under a parent node and inherit its policies.

## Responsibilities

- Create an organization node per department.
- Optionally create a department-admin CAM role (assumed from the management account).
- Optionally attach a manage policy to the department node.

It does **not**: create the manage policy (see `modules/control-policies`) or
member accounts (see `modules/account-factory`).

## Usage

```hcl
module "departments" {
  source         = "../../modules/department"
  parent_node_id = module.org.node_ids["workloads"]
  management_uin = var.management_uin

  departments = {
    engineering = { name = "Engineering" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on names. |
| `parent_node_id` | `number` | — | Parent node id. |
| `management_uin` | `string` | — | UIN allowed to assume admin roles. |
| `departments` | `map(object)` | — | Per-department name, admin role, manage policy. |

## Outputs

| Name | Description |
|---|---|
| `node_ids` | Map of department key to node id. |
| `admin_role_ids` | Map of department key to admin role id. |

## Security notes

- Department admin roles trust only the management account; scope tighter for production.
- Departments inherit organization deny guardrails from the parent node.

Validated via [live/15-departments](../../live/15-departments); see [../../tests](../../tests).
