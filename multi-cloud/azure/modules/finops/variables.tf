variable "name_prefix" {
  description = "Prefix applied to budget names."
  type        = string
  default     = "lz-"
}

variable "budgets" {
  description = <<-EOT
    Management-group budgets keyed by stable id. `start_date` must be the first
    day of a month (RFC3339). Notifications alert contacts at threshold percentages.
  EOT
  type = map(object({
    management_group_id = string
    amount              = number
    time_grain          = optional(string, "Monthly")
    start_date          = string
    notifications = optional(list(object({
      threshold      = number
      operator       = optional(string, "GreaterThan")
      threshold_type = optional(string, "Actual")
      contact_emails = list(string)
    })), [])
  }))
  default = {}
}
