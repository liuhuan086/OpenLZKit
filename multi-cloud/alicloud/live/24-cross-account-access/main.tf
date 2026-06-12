variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

variable "access_roles" {
  description = "Cross-account RAM roles to create in this target account."
  type = map(object({
    role_name          = string
    description        = optional(string, "")
    trusted_principals = list(string)
    system_policies    = optional(list(string), [])
    condition          = optional(any, null)
    tags               = optional(map(string), {})
  }))
  default = {}
}

variable "resource_shares" {
  description = "Resource Share definitions to create from this account."
  type = map(object({
    name                   = string
    allow_external_targets = optional(bool, false)
    permission_names       = optional(list(string), [])
    resource_arns          = optional(list(string), [])
    targets                = optional(list(string), [])
    resources = optional(list(object({
      resource_id   = string
      resource_type = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

provider "alicloud" {
  region = var.region
}

# 24-cross-account-access: target-account roles and Resource Share contracts.
# Inputs are empty by default to avoid accidental trust or resource sharing.
module "cross_account_access" {
  source = "../../modules/cross-account-access"

  name_prefix     = "lz-"
  access_roles    = var.access_roles
  resource_shares = var.resource_shares
}

output "cross_account_role_arns" {
  description = "Cross-account role ARNs by key."
  value       = module.cross_account_access.role_arns
}

output "resource_share_ids" {
  description = "Resource Share ids by key."
  value       = module.cross_account_access.resource_share_ids
}
