variable "region" {
  description = "Tencent Cloud region for the provider."
  type        = string
  default     = "ap-guangzhou"
}

variable "vpc_attachments" {
  description = "VPCs to attach to the hub CCN. Empty by default; never attach the sandbox VPC."
  type = map(object({
    instance_id     = string
    instance_region = string
  }))
  default = {}
}

provider "tencentcloud" {
  region = var.region
}

# 35-connectivity: a hub CCN with VPC attachments. Only attach VPCs that should
# interconnect (hub/dev/prod via shared services); the sandbox VPC stays off.
module "connectivity" {
  source      = "../../modules/connectivity"
  ccn_name    = "hub"
  attachments = var.vpc_attachments
}

output "ccn_id" {
  value = module.connectivity.ccn_id
}
