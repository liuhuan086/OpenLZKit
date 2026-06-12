# Module: gcp/project-factory

The GCP **multi-account (project) management** primitive: create projects into
the folder hierarchy with consistent labels and billing, and **no default
network** (`auto_create_network = false`).

## Responsibilities

- Create projects under a folder, linked to a billing account, with labels.
- Default to no auto-created network (avoids the insecure default VPC).

It does **not**: build the folder hierarchy (see `modules/org`), enable APIs, or
configure in-project baselines (IAM, network, logging).

## Usage

```hcl
module "projects" {
  source = "../../modules/project-factory"

  projects = {
    payment_prod = {
      name            = "payment-prod"
      project_id      = "lz-payment-prod"
      folder_id       = module.org.folder_names["workloads/prod"]
      billing_account = "0X0X0X-0X0X0X-0X0X0X"
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `projects` | `map(object)` | `{}` | Projects (name, project_id, folder_id, billing, labels). Billing impact. |
| `common_labels` | `map(string)` | `{}` | Labels merged onto every project. |

## Outputs

| Name | Description |
|---|---|
| `project_ids` | Map of key to project id. |
| `project_numbers` | Map of key to project number. |

## Security notes

- Project creation is opt-in and requires a billing account; enable with approvals.
- `auto_create_network = false` by default — create networks deliberately (Shared VPC).

Validated via [live/10-org](../../live/10-org); see [../../tests](../../tests).
