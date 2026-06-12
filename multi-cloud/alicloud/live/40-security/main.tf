variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

provider "alicloud" {
  region = var.region
}

# 40-security: account-wide RAM guardrails (strong passwords, enforced MFA,
# no user-managed AccessKeys). Applied to the management account.
module "security" {
  source = "../../modules/security"
}

output "password_policy_id" {
  value = module.security.password_policy_id
}
