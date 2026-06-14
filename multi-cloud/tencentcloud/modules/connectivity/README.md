# Module: tencentcloud/connectivity

**Network interconnect** (FP-6): a Cloud Connect Network (CCN) and VPC
attachments — Tencent Cloud's hub-spoke equivalent. Attach only VPCs that should
interconnect.

## Responsibilities

- Create a CCN (hub).
- Attach VPCs to the CCN.

It does **not**: create VPCs/subnets (see `modules/network`) or manage CCN
bandwidth packages / route tables in depth.

## Usage

```hcl
module "connectivity" {
  source   = "../../modules/connectivity"
  ccn_name = "hub"
  attachments = {
    prod = { instance_id = "vpc-xxxx", instance_region = "ap-guangzhou" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on the CCN name. |
| `ccn_name` | `string` | `hub` | CCN name. |
| `description` | `string` | — | CCN description. |
| `attachments` | `map(object)` | `{}` | VPCs to attach (instance_id, instance_region). |
| `tags` | `map(string)` | `{}` | Tags. |

## Outputs

| Name | Description |
|---|---|
| `ccn_id` | Created CCN id. |
| `attachment_ids` | Map of attachment key to id. |

## Security notes

- Attach only VPCs that should interconnect; **never** attach the sandbox VPC to the hub CCN.
- Use CCN route tables to segment traffic between attached VPCs.

Validated via [live/35-connectivity](../../live/35-connectivity); see [../../tests](../../tests).
