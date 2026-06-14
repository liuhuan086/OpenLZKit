variable "region" {
  description = "Tencent Cloud region for the provider."
  type        = string
  default     = "ap-guangzhou"
}

variable "security_account_uin" {
  description = "Root UIN of the security account allowed to assume the read-only audit role."
  type        = string
}

variable "audit_policy_ids" {
  description = "CAM policy ids attached to the cross-account audit role (e.g. a read-only preset). Empty by default."
  type        = list(number)
  default     = []
}

provider "tencentcloud" {
  region = var.region
}

# 24-cross-account-access: a read-only audit role in this account that the
# security account may assume via STS. Policies are environment-supplied.
module "cross_account" {
  source = "../../modules/cross-account-access"

  access_roles = {
    security-audit = {
      name         = "security-audit"
      description  = "Cross-account read-only audit role for the security account."
      trusted_uins = [var.security_account_uin]
      policy_ids   = var.audit_policy_ids
    }
  }
}

output "role_ids" {
  value = module.cross_account.role_ids
}
