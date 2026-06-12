# Module: azure/network

Creates one VNet with subnets and a **default-deny** baseline NSG associated to
every subnet. Compose it multiple times (hub + spokes) for a Hub-Spoke topology;
peering is layered on top.

## Responsibilities

- Create a VNet with a documented, non-overlapping address space.
- Create subnets and associate a baseline NSG (no custom rules → Azure default
  rules deny inbound from the internet).

It does **not**: peer VNets / create a Virtual WAN (see `modules/connectivity`),
or manage gateways/NAT/firewall.

## Usage

```hcl
module "prod" {
  source              = "../../modules/network"
  name                = "prod"
  resource_group_name = azurerm_resource_group.network.name
  location            = "eastus"
  address_space       = ["10.30.0.0/16"]
  subnets = {
    workload = { address_prefixes = ["10.30.1.0/24"] }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Logical VNet name. |
| `name_prefix` | `string` | `"lz-"` | Prefix on resource names. |
| `resource_group_name` | `string` | — | Target resource group. |
| `location` | `string` | — | Region. |
| `address_space` | `list(string)` | — | VNet space; must not overlap other VNets. |
| `subnets` | `map(object)` | — | Per-subnet address prefixes. |
| `tags` | `map(string)` | `{}` | Tags. |

## Outputs

| Name | Description |
|---|---|
| `vnet_id` | Created VNet id. |
| `subnet_ids` | Map of subnet name to id. |
| `baseline_nsg_id` | Default-deny NSG id. |

## Security notes

- The baseline NSG relies on Azure default rules, which deny inbound internet traffic.
- Keep address spaces documented and non-overlapping (prod/dev/sandbox/hub).

Validated via [live/30-network](../../live/30-network); see [../../tests](../../tests).
