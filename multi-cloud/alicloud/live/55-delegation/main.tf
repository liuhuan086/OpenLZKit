variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

variable "delegated_administrators" {
  description = "Resource Directory delegated administrators keyed by stable identifier."
  type = map(object({
    account_id        = string
    service_principal = string
  }))
  default = {}
}

variable "cloud_sso_delegate_account_id" {
  description = "Optional delegated account id for CloudSSO administration."
  type        = string
  default     = null
}

variable "resource_shares" {
  description = "Resource Share definitions for delegated/shared infrastructure resources."
  type = map(object({
    name                   = string
    allow_external_targets = optional(bool, false)
    permission_names       = optional(list(string), [])
    resource_arns          = optional(list(string), [])
    targets                = optional(list(string), [])
    resource_group_id      = optional(string, null)
    resources = optional(list(object({
      resource_id   = string
      resource_type = string
    })), [])
    resource_properties = optional(list(object({
      resource_arn = string
      property     = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

provider "alicloud" {
  region = var.region
}

module "delegation" {
  source = "../../modules/delegation"

  name_prefix                   = "lz-"
  delegated_administrators      = var.delegated_administrators
  cloud_sso_delegate_account_id = var.cloud_sso_delegate_account_id
  resource_shares               = var.resource_shares
}

output "delegated_administrator_ids" {
  description = "Delegated administrator ids by key."
  value       = module.delegation.delegated_administrator_ids
}

output "resource_share_ids" {
  description = "Resource Share ids by key."
  value       = module.delegation.resource_share_ids
}
