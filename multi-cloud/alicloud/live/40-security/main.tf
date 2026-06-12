variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

variable "control_policies" {
  description = "Optional Resource Directory control policies. Empty by default; roll out deliberately by folder/account."
  type = map(object({
    name            = string
    description     = optional(string, null)
    effect_scope    = string
    policy_document = string
    tags            = optional(map(string), {})
  }))
  default = {}
}

variable "control_policy_attachments" {
  description = "Optional Resource Directory control policy attachments keyed by stable identifier."
  type = map(object({
    policy_key = string
    target_id  = string
  }))
  default = {}
}

provider "alicloud" {
  region = var.region
}

# 40-security: account-wide RAM guardrails (strong passwords, enforced MFA,
# no user-managed AccessKeys). Applied to the management account.
module "security" {
  source = "../../modules/security"
}

module "control_policies" {
  source = "../../modules/control-policies"

  name_prefix = "lz-"
  policies    = var.control_policies
  attachments = var.control_policy_attachments
}

output "password_policy_id" {
  value = module.security.password_policy_id
}

output "control_policy_ids" {
  description = "Created Resource Directory control policy ids by key."
  value       = module.control_policies.policy_ids
}
