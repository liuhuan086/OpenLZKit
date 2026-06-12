# Module: gcp/network

Creates one VPC (no auto-created subnetworks) with subnets (VPC flow logs on,
private Google access) and an explicit **default-deny ingress** firewall.
Compose it for hub + spokes; Shared VPC attachment / NCC is layered on top.

## Responsibilities

- Create a custom-mode VPC and its subnets (flow logs enabled, private Google access).
- Add an explicit deny-all-ingress firewall (defence in depth on top of GCP's implicit deny).

It does **not**: attach service projects to a Shared VPC or create NCC hubs/spokes
(see `modules/connectivity`), or manage Cloud NAT/routers.

## Usage

```hcl
module "prod" {
  source  = "../../modules/network"
  name    = "prod"
  project = var.host_project_id
  subnets = {
    workload = { region = "us-central1", ip_cidr_range = "10.30.0.0/20" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Logical VPC name. |
| `name_prefix` | `string` | `"lz-"` | Prefix on resource names. |
| `project` | `string` | — | Host project for the VPC. |
| `subnets` | `map(object)` | — | Per-subnet `region` + `ip_cidr_range`. |

## Outputs

| Name | Description |
|---|---|
| `network_id` | VPC network id. |
| `network_self_link` | VPC self link. |
| `subnet_ids` | Map of subnet name to id. |

## Security notes

- `auto_create_subnetworks = false` — no insecure default subnets.
- VPC flow logs are enabled on every subnet; CIDRs must be documented and non-overlapping.
- The deny-all-ingress rule complements GCP's implicit deny; add scoped allow rules per workload.

Validated via [live/30-network](../../live/30-network); see [../../tests](../../tests).
