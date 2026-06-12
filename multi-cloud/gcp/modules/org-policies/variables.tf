variable "parent" {
  description = "Where policies are applied: \"organizations/<org_id>\" or \"folders/<folder_id>\"."
  type        = string
}

variable "boolean_policies" {
  description = <<-EOT
    Boolean-constraint org policies keyed by stable id, e.g.
    constraints/iam.disableServiceAccountKeyCreation. `enforce` true denies.
  EOT
  type = map(object({
    constraint = string
    enforce    = optional(bool, true)
  }))
  default = {}
}

variable "list_policies" {
  description = <<-EOT
    List-constraint org policies keyed by stable id, e.g.
    constraints/gcp.resourceLocations. Set allowed/denied values or deny_all/allow_all.
  EOT
  type = map(object({
    constraint     = string
    allowed_values = optional(list(string))
    denied_values  = optional(list(string))
    deny_all       = optional(bool)
    allow_all      = optional(bool)
  }))
  default = {}
}
