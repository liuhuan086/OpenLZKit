variable "billing_account" {
  description = "Billing account id the budgets belong to."
  type        = string
}

variable "budgets" {
  description = <<-EOT
    Cloud Billing budgets keyed by stable id. `amount_units` is the budget amount
    in whole currency units. `projects` (\"projects/<number>\") optionally scopes
    the budget; empty means the whole billing account. `threshold_percents` drive
    alert notifications.
  EOT
  type = map(object({
    display_name       = string
    amount_units       = number
    currency_code      = optional(string, "USD")
    projects           = optional(list(string), [])
    threshold_percents = optional(list(number), [0.8, 1.0])
  }))
  default = {}
}
