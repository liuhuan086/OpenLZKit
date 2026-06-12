# Module: azure/workload-onboarding

The standard **template for onboarding a new workload**: an isolated resource
group, a workload managed identity, and optional scoped team access, all tagged
with the full FinOps tag set. Instantiate once per workload + environment.

## Responsibilities

- Create a resource group (isolation boundary) for the workload.
- Create a user-assigned managed identity for the application.
- Optionally grant the workload team a role on the resource group (Entra group preferred).
- Emit the standard FinOps tags (`owner`, `cost_center`, `env`, `project`, `managed_by`, `data_classification`).

It does **not** deploy the workload's VNet/compute/data — the app team deploys
into the resource group under the platform network/security baselines.

## Usage

```hcl
module "payment_dev" {
  source             = "../../modules/workload-onboarding"
  workload_name      = "payment"
  env                = "dev"
  location           = "eastus"
  owner              = "app-team-payment"
  cost_center        = "cc-payment"
  admin_principal_id = "<entra-group-object-id>"
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `workload_name` | `string` | — | Short workload id. |
| `env` | `string` | — | `dev`/`staging`/`prod`/`sandbox` (validated). |
| `location` | `string` | — | Region. |
| `owner` / `cost_center` | `string` | — | FinOps tags. |
| `data_classification` | `string` | `"internal"` | Data classification tag. |
| `admin_principal_id` | `string` | `null` | Workload team group (null skips RBAC). |
| `admin_role` | `string` | `Contributor` | Role granted on the resource group. |
| `extra_tags` | `map(string)` | `{}` | Extra tags. |

## Outputs

| Name | Description |
|---|---|
| `resource_group_id` | Workload resource group id. |
| `identity_principal_id` | Workload managed identity principal id. |
| `tags` | Applied FinOps tag set. |

## Notes

- Tags match the `finops` require-tag policy, so onboarded workloads stay compliant.
- Team RBAC is scoped to the workload resource group only.

Validated via [live/70-workload-onboarding](../../live/70-workload-onboarding); see [../../tests](../../tests).
