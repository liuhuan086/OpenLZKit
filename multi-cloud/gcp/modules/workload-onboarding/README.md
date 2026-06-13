# Module: gcp/workload-onboarding

The standard **template for onboarding a new workload**: a workload service
account and optional scoped team access, with the standard FinOps label set
output for the project/resources. Instantiate once per workload + environment.

## Responsibilities

- Create a workload service account (impersonated; no keys).
- Optionally grant the workload team a role on the project (Cloud Identity group preferred).
- Emit the standard FinOps labels (`owner`, `cost_center`, `env`, `project`, `managed_by`, `data_classification`).

It does **not** create the project (see `project-factory`) or deploy the
workload's network/compute/data — the app team deploys under the platform baselines.

## Usage

```hcl
module "payment_dev" {
  source        = "../../modules/workload-onboarding"
  project       = var.workload_project_id
  workload_name = "payment"
  env           = "dev"
  owner         = "app-team-payment"
  cost_center   = "cc-payment"
  team_member   = "group:payment@example.com"
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `project` | `string` | — | Workload project. |
| `workload_name` | `string` | — | Short workload id. |
| `env` | `string` | — | `dev`/`staging`/`prod`/`sandbox` (validated). |
| `owner` / `cost_center` | `string` | — | FinOps labels. |
| `data_classification` | `string` | `"internal"` | Data classification label. |
| `team_member` | `string` | `null` | Workload team group (null skips IAM). |
| `team_role` | `string` | `roles/editor` | Role granted to the team. |
| `extra_labels` | `map(string)` | `{}` | Extra labels. |

## Outputs

| Name | Description |
|---|---|
| `service_account_email` | Workload service account email. |
| `labels` | Applied FinOps label set. |

## Notes

- Labels mirror the FinOps label keys; apply them to the project for cost attribution.
- Team IAM is scoped to the workload project only.

Validated via [live/70-workload-onboarding](../../live/70-workload-onboarding); see [../../tests](../../tests).
