variable "workload_project_id" {
  description = "Workload project id where the service account and IAM live."
  type        = string
}

variable "team_member" {
  description = "Cloud Identity group for the workload team. Null skips the IAM grant."
  type        = string
  default     = null
}

provider "google" {
  project = var.workload_project_id
}

# 70-workload-onboarding: template for onboarding a new workload. Creates a
# workload service account and (optionally) scoped team access, with the standard
# FinOps label set output for the project. Copy per workload/environment.
module "payment_dev" {
  source = "../../modules/workload-onboarding"

  project       = var.workload_project_id
  workload_name = "payment"
  env           = "dev"
  owner         = "app-team-payment"
  cost_center   = "cc-payment"
  team_member   = var.team_member
}

output "payment_dev_service_account_email" {
  value = module.payment_dev.service_account_email
}
