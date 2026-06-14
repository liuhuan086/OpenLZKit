variable "allocation_tag_keys" {
  description = "Tag keys enabled for cost allocation (FinOps attribution)."
  type        = list(string)
  default     = []
}

variable "budgets" {
  description = <<-EOT
    Cost budgets keyed by stable id. Empty by default — Tencent budgets require
    several bill/plan/period fields, so supply them deliberately. `warn_thresholds`
    drive alert notifications.
  EOT
  type = map(object({
    budget_name  = string
    budget_quota = string
    bill_type    = string
    cycle_type   = string
    fee_type     = string
    plan_type    = string
    period_begin = string
    period_end   = string
    budget_note  = optional(string)
    warn_thresholds = optional(list(object({
      warn_type       = number
      cal_type        = number
      threshold_value = string
    })), [])
  }))
  default = {}
}
