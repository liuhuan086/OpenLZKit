# Module: alicloud/workload-onboarding

The standard **template for onboarding a new workload**. Creates an isolated
resource group and a workload-scoped developer role, tagged with the full
FinOps tag set. Instantiate once per workload + environment.

## Responsibilities

- `alicloud_resource_manager_resource_group` — an isolation boundary for the workload's resources.
- `alicloud_ram_role` — a workload+env scoped developer role, assumable by the app team.
- Emits the standard FinOps tags (`owner`, `cost_center`, `env`, `project`, `managed_by`, `data_classification`).

It does **not** create the workload's VPC/compute/data — those are deployed by
the app team into the resource group, under the platform's network/security
baselines.

## Usage

```hcl
module "payment_dev" {
  source             = "../../modules/workload-onboarding"
  workload_name      = "payment"
  env                = "dev"
  owner              = "app-team-payment"
  cost_center        = "cc-payment"
  trusted_principals = ["acs:ram::123456789012:root"]
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `workload_name` | `string` | — | Short workload id. |
| `env` | `string` | — | `dev` / `staging` / `prod` / `sandbox` (validated). |
| `owner` | `string` | — | Owning team (tag). |
| `cost_center` | `string` | — | Cost center (tag). |
| `data_classification` | `string` | `"internal"` | Data classification tag. |
| `trusted_principals` | `list(string)` | — | Who may assume the developer role. |
| `name_prefix` | `string` | `"lz-"` | Resource name prefix. |
| `extra_tags` | `map(string)` | `{}` | Extra tags merged onto the standard set. |

## Outputs

| Name | Description |
|---|---|
| `resource_group_id` | Workload resource group id. |
| `developer_role_arn` | Workload developer role ARN. |
| `tags` | Applied FinOps tag set. |

## Notes

- Tags match `modules/finops` required keys, so onboarded workloads satisfy the tag policy.
- Production workloads should narrow `trusted_principals` and gate apply with approval.

Validated via [live/70-workload-onboarding](../../live/70-workload-onboarding); see [../../tests](../../tests).
