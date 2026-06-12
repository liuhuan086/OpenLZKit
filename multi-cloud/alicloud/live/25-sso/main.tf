variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

variable "create_directory" {
  description = "Create a CloudSSO directory. Set false to use an existing directory_id."
  type        = bool
  default     = true
}

variable "directory_id" {
  description = "Existing CloudSSO directory id when create_directory is false."
  type        = string
  default     = null
}

variable "directory_name" {
  description = "CloudSSO directory name when create_directory is true."
  type        = string
  default     = "lz-sso"
}

variable "groups" {
  description = "CloudSSO groups keyed by stable identifier."
  type = map(object({
    name        = string
    description = optional(string, "")
  }))
  default = {}
}

variable "access_configurations" {
  description = "CloudSSO access configurations keyed by stable identifier."
  type = map(object({
    name                             = string
    description                      = optional(string, "")
    session_duration                 = optional(number, 3600)
    relay_state                      = optional(string, null)
    force_remove_permission_policies = optional(bool, true)
    permission_policies = optional(list(object({
      name     = string
      type     = string
      document = optional(string, null)
    })), [])
  }))
  default = {}
}

variable "assignments" {
  description = "CloudSSO access assignments to accounts."
  type = map(object({
    access_configuration_key = string
    principal_type           = string
    principal_id             = optional(string, null)
    group_key                = optional(string, null)
    user_key                 = optional(string, null)
    target_id                = string
    target_type              = optional(string, "RD-Account")
    deprovision_strategy     = optional(string, "DeprovisionForLastAccessAssignmentOnAccount")
  }))
  default = {}
}

variable "provisionings" {
  description = "Optional CloudSSO access-configuration provisioning targets."
  type = map(object({
    access_configuration_key = string
    target_id                = string
    target_type              = optional(string, "RD-Account")
  }))
  default = {}
}

provider "alicloud" {
  region = var.region
}

# 25-sso: human access through CloudSSO. Groups, access configurations and
# assignments are empty by default so production rollout is deliberate.
module "sso" {
  source = "../../modules/sso"

  create_directory      = var.create_directory
  directory_id          = var.directory_id
  directory_name        = var.directory_name
  groups                = var.groups
  access_configurations = var.access_configurations
  assignments           = var.assignments
  provisionings         = var.provisionings
}

output "directory_id" {
  description = "CloudSSO directory id."
  value       = module.sso.directory_id
}

output "group_ids" {
  description = "CloudSSO group ids by key."
  value       = module.sso.group_ids
}

output "access_configuration_ids" {
  description = "CloudSSO access configuration ids by key."
  value       = module.sso.access_configuration_ids
}
