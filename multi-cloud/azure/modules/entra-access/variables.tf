variable "name_prefix" {
  description = "Prefix applied to Entra group display names."
  type        = string
  default     = "lz-"
}

variable "groups" {
  description = <<-EOT
    Entra ID security groups (access personas), keyed by stable id. People are
    added to groups (out of band / via IdP sync); groups receive RBAC, not users.
  EOT
  type = map(object({
    display_name = string
    description  = optional(string, "")
  }))
  default = {}
}

variable "role_assignments" {
  description = <<-EOT
    RBAC assignments granting a group a role at a scope. `group_key` references a
    key from `groups`; `scope` is a management group / subscription / resource id.
  EOT
  type = map(object({
    group_key            = string
    scope                = string
    role_definition_name = string
    description          = optional(string)
  }))
  default = {}
}
