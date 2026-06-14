variable "region" {
  description = "Tencent Cloud region for the provider."
  type        = string
  default     = "ap-guangzhou"
}

variable "area" {
  description = "Region (area) for the share unit."
  type        = string
  default     = "ap-guangzhou"
}

variable "member_delegations" {
  description = "Member auth-policy delegations (delegate management to a member sub-account). Empty by default."
  type = map(object({
    org_sub_account_uin = string
    policy_id           = number
  }))
  default = {}
}

provider "tencentcloud" {
  region = var.region
}

# 55-delegation: an organization share unit for resource sharing, plus optional
# least-privilege member delegations (FP-8).
module "delegation" {
  source = "../../modules/delegation"

  share_units = {
    network-sharing = {
      name        = "network-sharing"
      area        = var.area
      description = "Share unit for delegating shared network resources to workloads."
    }
  }

  member_delegations = var.member_delegations
}

output "share_unit_ids" {
  value = module.delegation.share_unit_ids
}
