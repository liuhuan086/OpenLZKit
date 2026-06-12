variable "subscription_id" {
  description = "Azure subscription id (the delegated subscription) for the provider."
  type        = string
}

variable "managing_tenant_id" {
  description = "Platform (managing) tenant id that receives delegated access."
  type        = string
}

variable "delegated_scope" {
  description = "Scope being delegated (subscription or resource group id)."
  type        = string
}

variable "ops_principal_id" {
  description = "Entra group object id in the managing tenant that gets Reader on the delegated scope."
  type        = string
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# 55-delegation: Azure Lighthouse delegated management (FP-8). Grants the platform
# tenant least-privilege (Reader) cross-tenant access; Owner is rejected by the module.
module "delegation" {
  source = "../../modules/delegation"

  delegations = {
    platform-readonly = {
      name               = "platform-readonly"
      description        = "Read-only delegated management for the platform team."
      managing_tenant_id = var.managing_tenant_id
      scope              = var.delegated_scope
      authorizations = [
        {
          principal_id           = var.ops_principal_id
          principal_display_name = "Platform Operations (Reader)"
          # Built-in Reader role id.
          role_definition_id = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
        },
      ]
    }
  }
}

output "lighthouse_definition_ids" {
  value = module.delegation.lighthouse_definition_ids
}
