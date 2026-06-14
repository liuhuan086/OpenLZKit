# Module: tencentcloud/network

Creates one VPC with subnets and a **default-deny** baseline security group.
Compose it (hub + spokes) for a Hub-Spoke topology; CCN connectivity is layered
on top.

## Responsibilities

- Create a VPC with a documented, non-overlapping CIDR.
- Create subnets across availability zones.
- Provide a baseline security group with **no rules** (inbound denied by default).

It does **not**: create CCN / attachments (see `modules/connectivity`), NAT, or
EIPs.

## Usage

```hcl
module "prod" {
  source     = "../../modules/network"
  name       = "prod"
  cidr_block = "10.30.0.0/16"
  subnets = {
    workload = { availability_zone = "ap-guangzhou-6", cidr_block = "10.30.1.0/24" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Logical VPC name. |
| `name_prefix` | `string` | `"lz-"` | Prefix on resource names. |
| `cidr_block` | `string` | — | VPC CIDR; must not overlap other VPCs. |
| `subnets` | `map(object)` | — | Per-subnet `availability_zone` + `cidr_block`. |
| `tags` | `map(string)` | `{}` | Tags. |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | Created VPC id. |
| `subnet_ids` | Map of subnet name to id. |
| `baseline_security_group_id` | Default-deny security group id. |

## Security notes

- No public ingress by default — the baseline SG has no inbound rules.
- CIDRs must be documented and non-overlapping (prod/dev/sandbox/hub).

Validated via [live/30-network](../../live/30-network); see [../../tests](../../tests).
