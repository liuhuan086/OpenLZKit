variable "name_prefix" {
  description = "Prefix applied to cross-account role and resource-share names."
  type        = string
  default     = ""
}

variable "max_session_duration" {
  description = "Max assume-role session duration in seconds."
  type        = number
  default     = 3600
}

variable "access_roles" {
  description = "Cross-account RAM roles to create in the target account."
  type = map(object({
    role_name          = string
    description        = optional(string, "")
    trusted_principals = list(string)
    system_policies    = optional(list(string), [])
    condition          = optional(any, null)
    tags               = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for _, role in var.access_roles : length(role.trusted_principals) > 0])
    error_message = "Each cross-account role must define at least one trusted_principal."
  }
}

variable "resource_shares" {
  description = "Alibaba Cloud Resource Share definitions."
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

variable "common_tags" {
  description = "Tags merged onto created roles and resource shares."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
