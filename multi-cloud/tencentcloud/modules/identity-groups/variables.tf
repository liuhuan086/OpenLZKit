variable "name_prefix" {
  description = "Prefix applied to CAM group names."
  type        = string
  default     = "lz-"
}

variable "groups" {
  description = <<-EOT
    CAM user groups (access personas) keyed by stable id. People are added to
    groups via SSO/membership; groups receive policies, not individual users.
    `policy_ids` are CAM policy ids attached to the group.
  EOT
  type = map(object({
    name       = string
    remark     = optional(string, "")
    policy_ids = optional(list(number), [])
  }))
  default = {}
}
