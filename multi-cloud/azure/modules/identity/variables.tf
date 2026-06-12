variable "name_prefix" {
  description = "Prefix applied to custom role definition names."
  type        = string
  default     = "lz-"
}

variable "custom_roles" {
  description = <<-EOT
    Custom RBAC role definitions keyed by stable id. `scope` is where the role is
    defined; `assignable_scopes` limits where it can be assigned. Keep `actions`
    least-privilege.
  EOT
  type = map(object({
    description       = optional(string, "")
    scope             = string
    assignable_scopes = list(string)
    actions           = optional(list(string), [])
    not_actions       = optional(list(string), [])
    data_actions      = optional(list(string), [])
    not_data_actions  = optional(list(string), [])
  }))
  default = {}
}

variable "role_assignments" {
  description = <<-EOT
    RBAC role assignments keyed by stable id. Set either `role_definition_name`
    (built-in role) or `custom_role_key` (a key from `custom_roles`). `principal_id`
    is an Entra object id (group preferred over user).
  EOT
  type = map(object({
    scope                = string
    principal_id         = string
    principal_type       = optional(string)
    role_definition_name = optional(string)
    custom_role_key      = optional(string)
    description          = optional(string)
  }))
  default = {}
}
