variable "name_prefix" {
  description = "Prefix applied to department folders, roles and tag policies."
  type        = string
  default     = ""
}

variable "parent_folder_id" {
  description = "Resource Directory folder id under which department folders are created."
  type        = string
}

variable "max_session_duration" {
  description = "Max assume-role session duration in seconds for department RAM roles."
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
    trusted_principals         = list(string)
    system_policies            = optional(list(string), ["ReadOnlyAccess"])
    control_policy_ids         = optional(list(string), [])
    envs                       = optional(list(string), ["dev", "staging", "prod"])
    data_classification_values = optional(list(string), ["internal", "confidential"])
    tags                       = optional(map(string), {})
  }))

  validation {
    condition     = alltrue([for _, department in var.departments : length(department.trusted_principals) > 0])
    error_message = "Each department must define at least one trusted_principal for its RAM role."
  }
}
