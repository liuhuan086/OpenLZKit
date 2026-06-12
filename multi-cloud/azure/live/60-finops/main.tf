variable "subscription_id" {
  description = "Azure subscription id for the provider."
  type        = string
}

variable "root_management_group_id" {
  description = "Management group resource id where the budget and tag policy apply."
  type        = string
}

variable "budget_amount" {
  description = "Monthly budget amount."
  type        = number
  default     = 1000
}

variable "budget_start_date" {
  description = "Budget start date (first of a month, RFC3339)."
  type        = string
  default     = "2026-01-01T00:00:00Z"
}

variable "budget_contact_emails" {
  description = "Emails notified at budget thresholds."
  type        = list(string)
  default     = []
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# 60-finops: budget with threshold alerts at the management group.
module "finops" {
  source = "../../modules/finops"

  budgets = {
    platform-monthly = {
      management_group_id = var.root_management_group_id
      amount              = var.budget_amount
      start_date          = var.budget_start_date
      notifications = [
        { threshold = 80, threshold_type = "Actual", contact_emails = var.budget_contact_emails },
        { threshold = 100, threshold_type = "Forecasted", contact_emails = var.budget_contact_emails },
      ]
    }
  }
}

# Enforce the FinOps owner tag via the built-in "Require a tag on resources" policy.
module "tag_policy" {
  source = "../../modules/policy-guardrails"

  policy_assignments = {
    require-owner-tag = {
      name                 = "lz-require-owner-tag"
      display_name         = "Require owner tag"
      management_group_id  = var.root_management_group_id
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
      parameters           = jsonencode({ tagName = { value = "owner" } })
    }
  }
}

output "budget_ids" {
  value = module.finops.budget_ids
}
