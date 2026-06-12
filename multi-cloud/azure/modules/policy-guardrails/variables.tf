variable "name_prefix" {
  description = "Prefix applied to custom policy definition names."
  type        = string
  default     = "lz-"
}

variable "policy_definitions" {
  description = <<-EOT
    Custom Azure Policy definitions keyed by stable id. `policy_rule` and
    `parameters` are JSON strings; `management_group_id` is where the definition lives.
  EOT
  type = map(object({
    display_name        = string
    description         = optional(string, "")
    mode                = optional(string, "All")
    management_group_id = string
    policy_rule         = string
    parameters          = optional(string)
  }))
  default = {}
}

variable "policy_assignments" {
  description = <<-EOT
    Policy assignments at management group scope. Set `policy_definition_key`
    (a key from `policy_definitions`) or `policy_definition_id` (a built-in policy id).
  EOT
  type = map(object({
    name                  = string
    display_name          = optional(string)
    management_group_id   = string
    policy_definition_key = optional(string)
    policy_definition_id  = optional(string)
    enforce               = optional(bool, true)
    parameters            = optional(string)
    location              = optional(string)
  }))
  default = {}
}
