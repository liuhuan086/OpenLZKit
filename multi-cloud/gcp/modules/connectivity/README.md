# Module: gcp/connectivity

**Network interconnect** (FP-6): enable a **Shared VPC host** project and attach
service projects to it. Shared VPC is GCP's hub-spoke equivalent — service
projects use the host's networks.

## Responsibilities

- Enable the Shared VPC host project.
- Attach service projects to the host.

It does **not**: create VPCs/subnets (see `modules/network`), grant subnet-level
IAM (see `modules/delegation`), or configure NCC.

## Usage

```hcl
module "connectivity" {
  source       = "../../modules/connectivity"
  host_project = var.host_project
  service_projects = {
    prod = { service_project = "lz-payment-prod" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `host_project` | `string` | — | Project to enable as Shared VPC host. |
| `service_projects` | `map(object)` | `{}` | Service projects to attach. |

## Outputs

| Name | Description |
|---|---|
| `host_project` | Shared VPC host project. |
| `attached_service_projects` | Map of key to attached service project. |

## Security notes

- Attach only projects that should share the host network; **never** attach sandbox to the production host.
- Grant subnet-level usage via IAM (see `modules/delegation`) rather than broad host access.

Validated via [live/35-connectivity](../../live/35-connectivity); see [../../tests](../../tests).
