variable "region" {
  description = "Alibaba Cloud region for the provider and SLS project."
  type        = string
  default     = "cn-hangzhou"
}

variable "audit_project_name" {
  description = "Globally-unique SLS project name for central audit logs."
  type        = string
}

provider "alicloud" {
  region = var.region
}

# 50-logging: central audit. Creates the SLS audit project/logstore and an
# organization ActionTrail trail delivering all management events to it.
module "logging" {
  source = "../../modules/logging"

  region             = var.region
  audit_project_name = var.audit_project_name
}

output "audit_project_name" {
  value = module.logging.audit_project_name
}
