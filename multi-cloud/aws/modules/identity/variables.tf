variable "name_prefix" {
  description = "Prefix applied to IAM policy names."
  type        = string
  default     = ""
}

variable "account_alias" {
  description = "Optional IAM account alias for human-readable account identification."
  type        = string
  default     = null

  validation {
    condition     = var.account_alias == null ? true : var.account_alias != ""
    error_message = "account_alias must be null or a non-empty string."
  }
}

variable "create_account_password_policy" {
  description = "Whether to manage the account password policy for emergency IAM users."
  type        = bool
  default     = false
}

variable "password_policy" {
  description = "Account password policy settings used when create_account_password_policy is true."
  type = object({
    minimum_password_length        = optional(number, 14)
    require_lowercase_characters   = optional(bool, true)
    require_uppercase_characters   = optional(bool, true)
    require_numbers                = optional(bool, true)
    require_symbols                = optional(bool, true)
    allow_users_to_change_password = optional(bool, true)
    hard_expiry                    = optional(bool, false)
    max_password_age               = optional(number, 90)
    password_reuse_prevention      = optional(number, 24)
  })
  default = {}
}

variable "permission_boundaries" {
  description = "IAM permission boundary policies keyed by stable identifier."
  type = map(object({
    name        = string
    description = optional(string, "")
    path        = optional(string, "/")
    policy      = string
    tags        = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for _, boundary in var.permission_boundaries : can(jsondecode(boundary.policy))])
    error_message = "Each permission boundary policy document must be valid JSON."
  }
}

variable "managed_policies" {
  description = "Customer managed IAM policies keyed by stable identifier."
  type = map(object({
    name        = string
    description = optional(string, "")
    path        = optional(string, "/")
    policy      = string
    tags        = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for _, policy in var.managed_policies : can(jsondecode(policy.policy))])
    error_message = "Each managed policy document must be valid JSON."
  }
}

variable "common_tags" {
  description = "Tags merged onto IAM policies that support tagging."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
