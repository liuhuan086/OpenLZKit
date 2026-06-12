variable "instance_arn" {
  description = "IAM Identity Center instance ARN."
  type        = string
}

variable "identity_store_id" {
  description = "Identity Store id associated with the IAM Identity Center instance."
  type        = string
}

variable "permission_sets" {
  description = "IAM Identity Center permission sets keyed by stable identifier."
  type = map(object({
    name                = string
    description         = optional(string, "")
    session_duration    = optional(string, "PT4H")
    relay_state         = optional(string, null)
    managed_policy_arns = optional(list(string), [])
    inline_policy       = optional(string, null)
    tags                = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, permission_set in var.permission_sets :
      permission_set.inline_policy == null ? true : can(jsondecode(permission_set.inline_policy))
    ])
    error_message = "Each permission set inline_policy must be valid JSON when provided."
  }
}

variable "assignments" {
  description = "IAM Identity Center account assignments keyed by stable identifier."
  type = map(object({
    permission_set_key = string
    principal_id       = string
    principal_type     = string
    target_id          = string
    target_type        = optional(string, "AWS_ACCOUNT")
  }))
  default = {}

  validation {
    condition     = alltrue([for _, assignment in var.assignments : contains(["GROUP", "USER"], assignment.principal_type)])
    error_message = "Each assignment principal_type must be GROUP or USER."
  }
}

variable "groups" {
  description = "Optional Identity Store groups keyed by stable identifier."
  type = map(object({
    display_name = string
    description  = optional(string, "")
  }))
  default = {}
}

variable "users" {
  description = "Optional Identity Store users keyed by stable identifier."
  type = map(object({
    user_name    = string
    display_name = string
    given_name   = string
    family_name  = string
    email        = string
  }))
  default = {}
}

variable "group_memberships" {
  description = "Optional Identity Store group memberships keyed by stable identifier."
  type = map(object({
    group_key = string
    user_key  = string
  }))
  default = {}
}

variable "common_tags" {
  description = "Tags merged onto permission sets."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
