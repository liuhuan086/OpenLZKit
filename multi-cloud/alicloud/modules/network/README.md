# Module: alicloud/network

Creates one VPC with its VSwitches and a **default-deny** baseline security
group. Compose it multiple times (hub + spokes) to build a Hub-Spoke topology;
inter-VPC connectivity (CEN / Transit Router) is layered on top.

## Responsibilities

- Create a VPC with a documented, non-overlapping CIDR.
- Create VSwitches across availability zones.
- Provide a baseline security group with **no ingress rules** (inbound denied by default).

It does **not**: create CEN/Transit Router, NAT, EIPs, or flow logs (flow logs
belong to the logging stack; connectivity is composed at the live layer).

## Usage

```hcl
module "prod" {
  source     = "../../modules/network"
  name       = "prod"
  cidr_block = "10.30.0.0/16"
  vswitches = {
    a = { zone_id = "cn-hangzhou-i", cidr_block = "10.30.1.0/24" }
    b = { zone_id = "cn-hangzhou-j", cidr_block = "10.30.2.0/24" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Logical VPC name (`hub`, `dev`, `prod`, …). |
| `name_prefix` | `string` | `"lz-"` | Prefix on resource names. |
| `cidr_block` | `string` | — | VPC CIDR; must not overlap other VPCs. |
| `vswitches` | `map(object)` | — | Per-zone sub-CIDRs (`zone_id`, `cidr_block`). |
| `tags` | `map(string)` | `{}` | Tags on all resources. |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | Created VPC id. |
| `vswitch_ids` | Map of vswitch key to id. |
| `baseline_security_group_id` | Default-deny security group id. |

## Security notes

- No public ingress by default — the baseline SG has no inbound rules.
- CIDRs must be documented and non-overlapping (prod/dev/sandbox/shared).
- sandbox↔prod direct connectivity must remain denied at the connectivity layer.

Validated via [live/30-network](../../live/30-network); see [../../tests](../../tests).
