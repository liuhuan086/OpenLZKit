# Module: alicloud/department

Creates a standard Alibaba Cloud business department boundary.

## Responsibilities

- Create one Resource Directory folder per business department.
- Create a department administration RAM role with explicit trusted principals.
- Attach pre-created Resource Directory control policies to each department folder.
- Create and attach department tag policies that pin `owner`, `cost_center`,
  allowed `env` values and allowed `data_classification` values.
- Export standard FinOps tags for account vending and workload onboarding.

It does **not**:

- Create member accounts — use `modules/account-factory` with `folder_ids`.
- Create the global control policies — use `modules/control-policies`.
- Configure CloudSSO access assignments — that comes in the SSO feature point.

## Preconditions

- Resource Directory is already enabled.
- `parent_folder_id` exists, usually a top-level `Departments` or `Workloads` folder.
- Control policies referenced in `control_policy_ids` already exist.
- Trusted principals are scoped to department owners, SSO roles or platform roles.

## Usage

```hcl
module "departments" {
  source = "../../modules/department"

  name_prefix      = "lz-"
  parent_folder_id = module.org.folder_ids["workloads"]

  departments = {
    payments = {
      display_name       = "Payments"
      owner              = "payments-platform"
      cost_center        = "cc-1001"
      trusted_principals = ["acs:ram::1234567890123456:root"]
      system_policies    = ["ReadOnlyAccess"]
      control_policy_ids = [module.control_policies.policy_ids["deny_disable_audit"]]
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `""` | Prefix applied to folders, roles and tag policies. |
| `parent_folder_id` | `string` | — | Folder id under which department folders are created. |
| `max_session_duration` | `number` | `3600` | Department role session duration. |
| `create_tag_policies` | `bool` | `true` | Create and attach department tag policies. |
| `departments` | `map(object)` | — | Department definitions keyed by stable identifier. |

## Outputs

| Name | Description |
|---|---|
| `folder_ids` | Department folder ids by key. |
| `role_names` | Department admin role names by key. |
| `role_arns` | Department admin role ARNs by key. |
| `tag_policy_ids` | Department tag policy ids by key. |
| `standard_tags` | Standard FinOps tags for downstream account/workload vending. |

## Security notes

- `trusted_principals` must be specific SSO/platform principals where possible;
  account root is acceptable only for bootstrap demos.
- Department roles should start read-only and gain write permissions through
  reviewed, workload-specific roles.
- Roll department control policies out in sandbox first before production.

## Testing

Static checks (no cloud account required):

```bash
terraform -chdir=examples/departments fmt -check -recursive
terraform -chdir=examples/departments init -backend=false
terraform -chdir=examples/departments validate
```

`plan`/`apply` require management-account Resource Directory and RAM permissions.
