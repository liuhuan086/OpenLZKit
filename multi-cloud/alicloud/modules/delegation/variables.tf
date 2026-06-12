variable "name_prefix" {
  description = "Prefix applied to resource share names."
  type        = string
  default     = ""
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

variable "common_tags" {
  description = "Tags merged onto every resource share."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
