variable "region" {
  description = "Tencent Cloud region for the provider."
  type        = string
  default     = "ap-guangzhou"
}

variable "admin_policy_ids" {
  description = "CAM policy ids attached to the platform-admins group. Empty by default."
  type        = list(number)
  default     = []
}

variable "auditor_policy_ids" {
  description = "CAM policy ids attached to the security-auditors group. Empty by default."
  type        = list(number)
  default     = []
}

provider "tencentcloud" {
  region = var.region
}

# 25-sso: human access via CAM user groups + policy attachments. People join
# groups via SSO/membership; groups (not users) receive policies.
module "groups" {
  source      = "../../modules/identity-groups"
  name_prefix = "lz-"

  groups = {
    platform-admins = {
      name       = "platform-admins"
      remark     = "Platform administrators"
      policy_ids = var.admin_policy_ids
    }
    security-auditors = {
      name       = "security-auditors"
      remark     = "Security auditors (read-only)"
      policy_ids = var.auditor_policy_ids
    }
  }
}

output "group_ids" {
  value = module.groups.group_ids
}
