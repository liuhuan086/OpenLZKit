variable "name_prefix" {
  description = "Prefix applied to department OUs, roles and tag policies."
  type        = string
  default     = ""
}

variable "parent_ou_id" {
  description = "AWS Organizations OU id under which department OUs are created."
  type        = string
}

variable "max_session_duration" {
  description = "Max assume-role session duration in seconds for department IAM roles."
  type        = number
  default     = 3600
}

variable "create_tag_policies" {
  description = "Create and attach department tag policies that pin owner and cost_center values."
  type        = bool
  default     = true
}

variable "departments" {
  description = "Departments keyed by stable identifier."
  type = map(object({
    display_name               = string
    owner                      = string
    cost_center                = string
    trusted_principal_arns     = list(string)
    managed_policy_arns        = optional(list(string), ["arn:aws:iam::aws:policy/ReadOnlyAccess"])
    organization_policy_ids    = optional(list(string), [])
    envs                       = optional(list(string), ["dev", "staging", "prod"])
    data_classification_values = optional(list(string), ["internal", "confidential"])
    tags                       = optional(map(string), {})
  }))

  validation {
    condition     = alltrue([for _, department in var.departments : length(department.trusted_principal_arns) > 0])
    error_message = "Each department must define at least one trusted_principal_arn for its IAM role."
  }

  validation {
    condition = alltrue(flatten([
      for _, department in var.departments : [
        for principal in department.trusted_principal_arns : principal != "*"
      ]
    ]))
    error_message = "Department trusted_principal_arns must not contain wildcard principals."
  }
}
