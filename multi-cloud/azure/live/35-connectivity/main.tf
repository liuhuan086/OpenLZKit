variable "subscription_id" {
  description = "Azure subscription id (connectivity) for the provider."
  type        = string
}

variable "network_resource_group_name" {
  description = "Resource group holding the VNets (from live/30-network)."
  type        = string
  default     = "lz-network-rg"
}

variable "hub_vnet_name" {
  description = "Hub VNet name."
  type        = string
  default     = "lz-hub"
}

variable "hub_vnet_id" {
  description = "Hub VNet resource id."
  type        = string
}

variable "spoke_vnets" {
  description = "Spoke VNets to peer with the hub, keyed by name: { vnet_name, vnet_id }."
  type = map(object({
    vnet_name = string
    vnet_id   = string
  }))
  default = {}
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# 35-connectivity: Hub-Spoke peering. Each spoke peers bidirectionally with the
# hub only; spoke<->spoke (e.g. dev<->prod, sandbox<->prod) is intentionally
# omitted so those paths stay denied.
module "connectivity" {
  source = "../../modules/connectivity"

  peerings = merge(
    {
      for k, spoke in var.spoke_vnets :
      "hub-to-${k}" => {
        resource_group_name       = var.network_resource_group_name
        virtual_network_name      = var.hub_vnet_name
        remote_virtual_network_id = spoke.vnet_id
        allow_gateway_transit     = true
      }
    },
    {
      for k, spoke in var.spoke_vnets :
      "${k}-to-hub" => {
        resource_group_name       = var.network_resource_group_name
        virtual_network_name      = spoke.vnet_name
        remote_virtual_network_id = var.hub_vnet_id
        use_remote_gateways       = false
      }
    },
  )
}

output "peering_ids" {
  value = module.connectivity.peering_ids
}
