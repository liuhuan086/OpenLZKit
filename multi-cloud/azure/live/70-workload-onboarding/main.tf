variable "subscription_id" {
  description = "Azure subscription id (workload subscription) for the provider."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "team_principal_id" {
  description = "Entra group object id for the workload team. Null skips the RBAC grant."
  type        = string
  default     = null
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# 70-workload-onboarding: template for onboarding a new workload. Creates an
# isolated resource group, a workload managed identity, and (optionally) scoped
# team access, all tagged with the standard FinOps tag set. Copy per workload/env.
module "payment_dev" {
  source = "../../modules/workload-onboarding"

  workload_name      = "payment"
  env                = "dev"
  location           = var.location
  owner              = "app-team-payment"
  cost_center        = "cc-payment"
  admin_principal_id = var.team_principal_id
}

output "payment_dev_resource_group_id" {
  value = module.payment_dev.resource_group_id
}
