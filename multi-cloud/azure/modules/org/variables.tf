variable "name_prefix" {
  description = "Prefix applied to every management group name (the immutable id), e.g. \"lz-\"."
  type        = string
  default     = "lz-"
}

variable "parent_management_group_id" {
  description = "Full resource id of the parent management group. Null places the top-level groups under the tenant root group."
  type        = string
  default     = null
}

variable "management_groups" {
  description = <<-EOT
    Management group hierarchy. The map key is a stable id (used to build the
    management group name and to reference it from other modules); `display_name`
    is the friendly name; `children` defines one optional level of nested groups.
  EOT
  type = map(object({
    display_name = string
    children     = optional(map(object({ display_name = string })), {})
  }))
}
