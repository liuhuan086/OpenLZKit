variable "region" {
  description = "AWS region for delegated administrator and RAM resources."
  type        = string
  default     = "us-east-1"
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
