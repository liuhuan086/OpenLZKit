variable "name_prefix" {
  description = "Prefix applied to department folder display names."
  type        = string
  default     = "lz-"
}

variable "parent" {
  description = "Parent folder/org for department folders (\"folders/<id>\" or \"organizations/<id>\")."
  type        = string
}

variable "billing_account" {
  description = "Billing account id for department budgets. Required if any department sets a budget."
  type        = string
  default     = null
}

variable "departments" {
  description = <<-EOT
    Business departments keyed by stable id. Each gets its own folder, an optional
    admin IAM binding (Cloud Identity group preferred), and an optional budget
    scoped to the folder.
  EOT
  type = map(object({
    display_name       = string
    admin_member       = optional(string)
    admin_role         = optional(string, "roles/resourcemanager.folderAdmin")
    budget_units       = optional(number)
    threshold_percents = optional(list(number), [0.9])
  }))
}
