variable "subscription_id" {
  description = "Azure subscription id for the provider."
  type        = string
}

variable "subscription_associations" {
  description = "Existing subscriptions to place into management groups. Empty by default."
  type = map(object({
    management_group_key = string
    subscription_id      = string
  }))
  default = {}
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# 10-org: management group hierarchy mirroring docs/design account model.
module "org" {
  source      = "../../modules/org"
  name_prefix = "lz-"

  management_groups = {
    platform = {
      display_name = "Platform"
      children = {
        identity     = { display_name = "Identity" }
        management   = { display_name = "Management" }
        connectivity = { display_name = "Connectivity" }
      }
    }
    landingzones = {
      display_name = "Landing Zones"
      children = {
        corp   = { display_name = "Corp" }
        online = { display_name = "Online" }
      }
    }
    sandbox = {
      display_name = "Sandbox"
    }
    decommissioned = {
      display_name = "Decommissioned"
    }
  }
}

# Subscription vending wired here but disabled by default (billing impact).
module "subscriptions" {
  source = "../../modules/subscription-vending"

  associations = {
    for key, assoc in var.subscription_associations :
    key => {
      management_group_id = module.org.management_group_ids[assoc.management_group_key]
      subscription_id     = assoc.subscription_id
    }
  }
}

output "management_group_ids" {
  description = "Created management group ids by key."
  value       = module.org.management_group_ids
}
