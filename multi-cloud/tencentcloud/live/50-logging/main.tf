variable "region" {
  description = "Tencent Cloud region for the provider and CLS topic."
  type        = string
  default     = "ap-guangzhou"
}

provider "tencentcloud" {
  region = var.region
}

# 50-logging: central audit. Creates a CLS logset/topic and an organization-wide
# CloudAudit track delivering management (write) events to it.
module "logging" {
  source = "../../modules/logging"
  region = var.region
}

output "topic_id" {
  value = module.logging.topic_id
}
