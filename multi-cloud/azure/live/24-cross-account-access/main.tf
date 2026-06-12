variable "subscription_id" {
  description = "Azure subscription id (platform) for the provider."
  type        = string
}

variable "identity_resource_group_name" {
  description = "Resource group for platform managed identities."
  type        = string
  default     = "lz-identity-rg"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "github_owner" {
  description = "GitHub org/user for the CI managed identity federation."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository for the CI managed identity federation."
  type        = string
}

variable "workload_role_assignments" {
  description = "Cross-subscription role assignments granted to the CI deployer identity. Empty by default."
  type = map(object({
    scope                = string
    role_definition_name = string
  }))
  default = {}
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "identity" {
  name     = var.identity_resource_group_name
  location = var.location
}

# 24-cross-account-access: a CI deployer machine identity federated to GitHub
# Actions, granted least-privilege roles into target (workload) subscriptions.
module "cross_account" {
  source = "../../modules/cross-account-access"

  managed_identities = {
    cicd-deployer = {
      resource_group_name = azurerm_resource_group.identity.name
      location            = var.location
      federated_credentials = {
        main = {
          issuer  = "https://token.actions.githubusercontent.com"
          subject = "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/main"
        }
      }
    }
  }

  role_assignments = {
    for key, ra in var.workload_role_assignments :
    key => {
      scope                = ra.scope
      role_definition_name = ra.role_definition_name
      managed_identity_key = "cicd-deployer"
    }
  }
}

output "cicd_client_id" {
  value = module.cross_account.managed_identity_client_ids["cicd-deployer"]
}
