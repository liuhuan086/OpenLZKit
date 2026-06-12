variable "region" {
  description = "AWS region used for provider initialization."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix applied to IAM policy names."
  type        = string
  default     = ""
}

variable "account_alias" {
  description = "Optional IAM account alias for human-readable account identification."
  type        = string
  default     = null
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
}

variable "common_tags" {
  description = "Tags merged onto IAM policies that support tagging."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
