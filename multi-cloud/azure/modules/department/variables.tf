variable "name_prefix" {
  description = "Prefix applied to department management group names."
  type        = string
  default     = "lz-"
}

variable "parent_management_group_id" {
  description = "Parent management group resource id under which department groups are created."
  type        = string
}

variable "departments" {
  description = <<-EOT
    Business departments keyed by stable id. Each gets its own management group,
    an optional admin RBAC assignment (Entra group preferred), and an optional budget.
  EOT
  type = map(object({
    display_name          = string
    admin_principal_id    = optional(string)
    admin_role            = optional(string, "Contributor")
    admin_principal_type  = optional(string, "Group")
    budget_amount         = optional(number)
    budget_start_date     = optional(string)
    budget_contact_emails = optional(list(string), [])
  }))
}
