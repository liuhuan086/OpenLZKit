# Module: tencentcloud/workload-onboarding

The standard **template for onboarding a new workload**: a workload CAM role
tagged with the full FinOps tag set, with optional policy attachments.
Instantiate once per workload + environment.

## Responsibilities

- Create a workload CAM role (assumed via STS; no SecretKey).
- Optionally attach team policies to the role.
- Apply the standard FinOps tags (`owner`, `cost_center`, `env`, `project`, `managed_by`, `data_classification`).

It does **not** create member accounts (see `account-factory`) or deploy the
workload's network/compute/data — the app team deploys under the platform baselines.

## Usage

```hcl
module "payment_dev" {
  source         = "../../modules/workload-onboarding"
  workload_name  = "payment"
  env            = "dev"
  owner          = "app-team-payment"
  cost_center    = "cc-payment"
  management_uin = var.management_uin
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `workload_name` | `string` | — | Short workload id. |
| `env` | `string` | — | `dev`/`staging`/`prod`/`sandbox` (validated). |
| `owner` / `cost_center` | `string` | — | FinOps tags. |
| `data_classification` | `string` | `"internal"` | Data classification tag. |
| `management_uin` | `string` | — | UIN allowed to assume the role. |
| `team_policy_ids` | `list(number)` | `[]` | Policies attached to the role. |
| `extra_tags` | `map(string)` | `{}` | Extra tags. |

## Outputs

| Name | Description |
|---|---|
| `role_id` | Workload CAM role id. |
| `tags` | Applied FinOps tag set. |

## Notes

- Tags mirror the FinOps allocation tags so onboarded workloads are attributable.
- The role is assumed via STS — no long-lived SecretKey.

Validated via [live/70-workload-onboarding](../../live/70-workload-onboarding); see [../../tests](../../tests).
