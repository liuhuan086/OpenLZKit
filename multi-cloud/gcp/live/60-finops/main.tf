variable "project_id" {
  description = "Project id for the provider."
  type        = string
}

variable "billing_account" {
  description = "Billing account id the budgets belong to."
  type        = string
}

variable "monthly_budget_units" {
  description = "Platform monthly budget amount in whole currency units."
  type        = number
  default     = 1000
}

provider "google" {
  project = var.project_id
}

# 60-finops: a platform-wide budget with 80% / 100% threshold alerts.
module "finops" {
  source          = "../../modules/finops"
  billing_account = var.billing_account

  budgets = {
    platform-monthly = {
      display_name       = "lz-platform-monthly"
      amount_units       = var.monthly_budget_units
      threshold_percents = [0.8, 1.0]
    }
  }
}

output "budget_ids" {
  value = module.finops.budget_ids
}
