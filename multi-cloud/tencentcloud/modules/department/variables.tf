variable "name_prefix" {
  description = "Prefix applied to department node and role names."
  type        = string
  default     = "lz-"
}

variable "parent_node_id" {
  description = "Parent organization node id under which department nodes are created."
  type        = number
}

variable "management_uin" {
  description = "Root UIN allowed to assume department admin roles."
  type        = string
}

variable "departments" {
  description = <<-EOT
    Business departments keyed by stable id. Each gets its own organization node,
    an optional department-admin CAM role, and an optional manage-policy attachment
    to the node.
  EOT
  type = map(object({
    name              = string
    create_admin_role = optional(bool, true)
    manage_policy_id  = optional(number)
  }))
}
