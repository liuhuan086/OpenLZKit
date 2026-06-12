variable "subscription_id" {
  description = "Azure subscription id (management/logging subscription) for the provider."
  type        = string
}

variable "location" {
  description = "Azure region for the workspace."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group for the central Log Analytics workspace."
  type        = string
  default     = "lz-logging-rg"
}

variable "workspace_name" {
  description = "Central Log Analytics workspace name."
  type        = string
  default     = "central-audit"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "logging" {
  name     = var.resource_group_name
  location = var.location
}

# 50-logging: central audit sink. Resource diagnostic settings are attached per
# environment via the module's diagnostic_settings input.
module "logging" {
  source              = "../../modules/logging"
  resource_group_name = azurerm_resource_group.logging.name
  location            = var.location
  workspace_name      = var.workspace_name
}

output "workspace_id" {
  value = module.logging.workspace_id
}
