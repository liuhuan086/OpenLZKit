variable "subscription_id" {
  description = "Azure subscription id for the provider."
  type        = string
}

variable "root_management_group_id" {
  description = "Management group resource id where platform personas are granted access."
  type        = string
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {}

# 25-sso: human access via Entra ID security groups + RBAC at management group
# scope. People are added to groups via the IdP; groups (not users) get roles.
module "entra_access" {
  source      = "../../modules/entra-access"
  name_prefix = "lz-"

  groups = {
    platform-admins   = { display_name = "Platform Admins", description = "Platform infrastructure administrators." }
    security-auditors = { display_name = "Security Auditors", description = "Read-only security and audit." }
  }

  role_assignments = {
    platform-admins = {
      group_key            = "platform-admins"
      scope                = var.root_management_group_id
      role_definition_name = "Contributor"
    }
    security-auditors = {
      group_key            = "security-auditors"
      scope                = var.root_management_group_id
      role_definition_name = "Reader"
    }
  }
}

output "group_object_ids" {
  value = module.entra_access.group_object_ids
}
