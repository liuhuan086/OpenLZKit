variable "region" {
  description = "Tencent Cloud region for the provider."
  type        = string
  default     = "ap-guangzhou"
}

variable "management_uin" {
  description = "Root UIN allowed to assume the workload role."
  type        = string
}

provider "tencentcloud" {
  region = var.region
}

# 70-workload-onboarding: template for onboarding a new workload. Creates a
# workload CAM role tagged with the standard FinOps tag set. Copy per workload/env.
module "payment_dev" {
  source = "../../modules/workload-onboarding"

  workload_name  = "payment"
  env            = "dev"
  owner          = "app-team-payment"
  cost_center    = "cc-payment"
  management_uin = var.management_uin
}

output "payment_dev_role_id" {
  value = module.payment_dev.role_id
}
