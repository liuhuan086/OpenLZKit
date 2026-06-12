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

variable "mfa_authentication_status" {
  description = "CloudSSO MFA status for the directory."
  type        = string
  default     = "Enabled"
}

variable "directory_global_access_status" {
  description = "CloudSSO global access status."
  type        = string
  default     = "Enabled"
}

variable "scim_synchronization_status" {
  description = "SCIM synchronization status for the directory."
  type        = string
  default     = null
}

variable "login_network_masks" {
  description = "Optional login network masks for CloudSSO."
  type        = string
  default     = null
}

variable "allow_user_to_get_credentials" {
  description = "Allow users to get temporary credentials from CloudSSO."
  type        = bool
  default     = false
}

variable "groups" {
  description = "CloudSSO groups keyed by stable identifier."
  type = map(object({
    name        = string
    description = optional(string, "")
  }))
  default = {}
}

variable "users" {
  description = "Optional local CloudSSO users keyed by stable identifier. Prefer SCIM for production identities."
  type = map(object({
    user_name   = string
    display_name = optional(string, null)
    email       = optional(string, null)
    first_name  = optional(string, null)
    last_name   = optional(string, null)
    description = optional(string, null)
    status      = optional(string, null)
    tags        = optional(map(string), {})
  }))
  default = {}
}

variable "group_memberships" {
  description = "Group memberships for local CloudSSO users."
  type = map(object({
    group_key = string
    user_key  = string
  }))
  default = {}
}

variable "access_configurations" {
  description = "CloudSSO access configurations keyed by stable identifier."
  type = map(object({
    name                                     = string
    description                              = optional(string, "")
    session_duration                         = optional(number, 3600)
    relay_state                              = optional(string, null)
    force_remove_permission_policies         = optional(bool, true)
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

variable "common_tags" {
  description = "Tags merged onto local CloudSSO users."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
