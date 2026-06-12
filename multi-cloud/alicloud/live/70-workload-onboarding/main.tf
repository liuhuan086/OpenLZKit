variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

variable "trusted_account_id" {
  description = "Account id whose app-team principals may assume the workload role."
  type        = string
}

provider "alicloud" {
  region = var.region
}

# 70-workload-onboarding: template for onboarding a new workload. Creates an
# isolated resource group + a workload-scoped developer role with the standard
# FinOps tags. Copy this block per workload/environment.
module "payment_dev" {
  source = "../../modules/workload-onboarding"

  workload_name      = "payment"
  env                = "dev"
  owner              = "app-team-payment"
  cost_center        = "cc-payment"
  trusted_principals = ["acs:ram::${var.trusted_account_id}:root"]
}

output "payment_dev_resource_group_id" {
  value = module.payment_dev.resource_group_id
}
