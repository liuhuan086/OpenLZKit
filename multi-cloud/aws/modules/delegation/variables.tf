variable "name_prefix" {
  description = "Prefix applied to AWS RAM resource share names."
  type        = string
  default     = ""
}

variable "enable_ram_sharing_with_organization" {
  description = "Enable AWS RAM sharing with AWS Organizations."
  type        = bool
  default     = false
}

variable "delegated_administrators" {
  description = "Organizations delegated administrators keyed by stable identifier."
  type = map(object({
    account_id        = string
    service_principal = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, admin in var.delegated_administrators :
      can(regex("^[a-z0-9.-]+\\.amazonaws\\.com$", admin.service_principal))
    ])
    error_message = "Each delegated administrator service_principal must be a precise AWS service principal, for example config.amazonaws.com."
  }
}

variable "resource_shares" {
  description = "AWS RAM resource shares keyed by stable identifier."
  type = map(object({
    name                      = string
    allow_external_principals = optional(bool, false)
    principals                = optional(list(string), [])
    resource_arns             = optional(list(string), [])
    permission_arns           = optional(list(string), [])
    tags                      = optional(map(string), {})
  }))
  default = {}
}

variable "common_tags" {
  description = "Tags merged onto created RAM resource shares."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
