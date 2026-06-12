variable "subscription_id" {
  description = "Azure subscription id (connectivity subscription) for the provider."
  type        = string
}

variable "location" {
  description = "Azure region for the networks."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group holding the Landing Zone networks."
  type        = string
  default     = "lz-network-rg"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "network" {
  name     = var.resource_group_name
  location = var.location
}

# Hub-Spoke baseline with non-overlapping address spaces. Peering and the
# sandbox->prod deny are layered in live/35-connectivity.
module "hub" {
  source              = "../../modules/network"
  name                = "hub"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  subnets = {
    shared  = { address_prefixes = ["10.0.1.0/24"] }
    gateway = { address_prefixes = ["10.0.2.0/24"] }
  }
}

module "dev" {
  source              = "../../modules/network"
  name                = "dev"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  address_space       = ["10.10.0.0/16"]
  subnets = {
    workload = { address_prefixes = ["10.10.1.0/24"] }
  }
}

module "prod" {
  source              = "../../modules/network"
  name                = "prod"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  address_space       = ["10.30.0.0/16"]
  subnets = {
    workload = { address_prefixes = ["10.30.1.0/24"] }
  }
}

output "vnet_ids" {
  description = "VNet ids by tier."
  value = {
    hub  = module.hub.vnet_id
    dev  = module.dev.vnet_id
    prod = module.prod.vnet_id
  }
}
