variable "budgets" {
  description = "AWS Budgets keyed by stable identifier."
  type = map(object({
    name         = string
    budget_type  = optional(string, "COST")
    limit_amount = string
    limit_unit   = optional(string, "USD")
    time_unit    = optional(string, "MONTHLY")
    cost_filters = optional(map(list(string)), {})
    notifications = optional(list(object({
      comparison_operator        = string
      threshold                  = number
      threshold_type             = optional(string, "PERCENTAGE")
      notification_type          = string
      subscriber_email_addresses = optional(list(string), [])
      subscriber_sns_topic_arns  = optional(list(string), [])
    })), [])
  }))
  default = {}
}

variable "anomaly_monitors" {
  description = "Cost Anomaly Detection monitors keyed by stable identifier."
  type = map(object({
    name                  = string
    monitor_type          = string
    monitor_dimension     = optional(string, null)
    monitor_specification = optional(string, null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, monitor in var.anomaly_monitors :
      monitor.monitor_specification == null ? true : can(jsondecode(monitor.monitor_specification))
    ])
    error_message = "Each anomaly monitor monitor_specification must be valid JSON when provided."
  }
}

variable "anomaly_subscriptions" {
  description = "Cost Anomaly Detection subscriptions keyed by stable identifier."
  type = map(object({
    name              = string
    frequency         = string
    monitor_keys      = list(string)
    subscriber_emails = optional(list(string), [])
    subscriber_sns    = optional(list(string), [])
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for _, subscription in var.anomaly_subscriptions : [
        for monitor_key in subscription.monitor_keys : contains(keys(var.anomaly_monitors), monitor_key)
      ]
    ]))
    error_message = "Each anomaly subscription monitor_key must exist in var.anomaly_monitors."
  }
}

variable "cost_categories" {
  description = "Cost Categories keyed by stable identifier."
  type = map(object({
    name         = string
    rule_version = optional(string, "CostCategoryExpression.v1")
    rules = list(object({
      value = string
      dimension = object({
        key           = string
        values        = list(string)
        match_options = optional(list(string), ["EQUALS"])
      })
    }))
  }))
  default = {}
}
