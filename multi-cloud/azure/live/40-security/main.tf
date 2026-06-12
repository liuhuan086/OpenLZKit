variable "subscription_id" {
  description = "Azure subscription id for the provider."
  type        = string
}

variable "root_management_group_id" {
  description = "Management group resource id where guardrail policies are defined and assigned (e.g. the platform root)."
  type        = string
}

variable "allowed_locations" {
  description = "Regions resources may be deployed in."
  type        = list(string)
  default     = ["eastus", "westeurope", "global"]
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# 40-security: organization guardrails as Azure Policy (deny by default).
module "policy_guardrails" {
  source      = "../../modules/policy-guardrails"
  name_prefix = "lz-"

  policy_definitions = {
    allowed-locations = {
      display_name        = "Allowed locations"
      description         = "Deny resources outside the approved regions."
      management_group_id = var.root_management_group_id
      policy_rule = jsonencode({
        if = {
          not = {
            field = "location"
            in    = var.allowed_locations
          }
        }
        then = { effect = "deny" }
      })
    }
    deny-storage-public-blob = {
      display_name        = "Deny public blob access on storage accounts"
      description         = "Storage accounts must disable public blob access."
      management_group_id = var.root_management_group_id
      policy_rule = jsonencode({
        if = {
          allOf = [
            { field = "type", equals = "Microsoft.Storage/storageAccounts" },
            { field = "Microsoft.Storage/storageAccounts/allowBlobPublicAccess", equals = true },
          ]
        }
        then = { effect = "deny" }
      })
    }
  }

  policy_assignments = {
    allowed-locations = {
      name                  = "lz-allowed-locations"
      display_name          = "Allowed locations"
      management_group_id   = var.root_management_group_id
      policy_definition_key = "allowed-locations"
    }
    deny-storage-public-blob = {
      name                  = "lz-deny-storage-public"
      display_name          = "Deny public blob access"
      management_group_id   = var.root_management_group_id
      policy_definition_key = "deny-storage-public-blob"
    }
  }
}

output "policy_assignment_ids" {
  value = module.policy_guardrails.policy_assignment_ids
}
