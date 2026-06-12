variable "subscription_id" {
  description = "Azure subscription id to enable Defender on (run per subscription)."
  type        = string
}

variable "security_contact_email" {
  description = "Email for Defender for Cloud alerts. Empty skips the contact."
  type        = string
  default     = ""
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# 45-compliance: Microsoft Defender for Cloud plans + alert contact. Runtime
# compliance that complements plan-time Conftest policy. Apply per subscription.
module "compliance" {
  source = "../../modules/compliance"

  defender_plans = {
    VirtualMachines = { tier = "Standard" }
    StorageAccounts = { tier = "Standard" }
    KeyVaults       = { tier = "Standard" }
    Containers      = { tier = "Standard" }
    Arm             = { tier = "Standard" }
  }

  security_contact = var.security_contact_email == "" ? null : {
    name  = "lz-security"
    email = var.security_contact_email
  }
}

output "defender_plan_ids" {
  value = module.compliance.defender_plan_ids
}
