variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

variable "attach_target_id" {
  description = "Resource Directory root/folder id to attach the tag policy to. Null = create policy only."
  type        = string
  default     = null
}

provider "alicloud" {
  region = var.region
}

# 60-finops: enforce the FinOps tag set Resource-Directory-wide.
module "finops" {
  source = "../../modules/finops"

  attach_target_id = var.attach_target_id
}

output "tag_policy_id" {
  value = module.finops.policy_id
}
