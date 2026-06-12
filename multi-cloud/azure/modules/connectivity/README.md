# Module: azure/connectivity

**Network interconnect** (FP-6): VNet peerings for a Hub-Spoke topology. Create
explicit peerings only for allowed paths (hub↔spoke); omit denied paths so they
stay isolated.

## Responsibilities

- Create `azurerm_virtual_network_peering` entries (with gateway transit options).

It does **not**: create VNets (see `modules/network`), deploy a Virtual WAN hub,
or manage Azure Firewall/route tables.

## Usage

```hcl
module "connectivity" {
  source = "../../modules/connectivity"

  peerings = {
    hub-to-prod = {
      resource_group_name       = "lz-network-rg"
      virtual_network_name      = "lz-hub"
      remote_virtual_network_id = module.prod.vnet_id
      allow_gateway_transit     = true
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on peering names. |
| `peerings` | `map(object)` | `{}` | Peerings (rg, vnet name, remote vnet id, gateway flags). |

## Outputs

| Name | Description |
|---|---|
| `peering_ids` | Map of peering key to id. |

## Security notes

- Only peer hub↔spoke; **never** create spoke↔spoke peerings for isolated tiers (sandbox↔prod).
- Route internet egress and inspection through the hub.

Validated via [live/35-connectivity](../../live/35-connectivity); see [../../tests](../../tests).
