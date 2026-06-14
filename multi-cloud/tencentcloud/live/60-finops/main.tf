variable "region" {
  description = "Tencent Cloud region for the provider."
  type        = string
  default     = "ap-guangzhou"
}

provider "tencentcloud" {
  region = var.region
}

# 60-finops: enable the FinOps tag set for cost allocation. Budgets are opt-in via
# the module's budgets input (Tencent budgets require several bill/plan fields).
module "finops" {
  source = "../../modules/finops"

  allocation_tag_keys = ["owner", "cost_center", "env", "project"]
}

output "allocation_tag_keys" {
  value = module.finops.allocation_tag_keys
}
