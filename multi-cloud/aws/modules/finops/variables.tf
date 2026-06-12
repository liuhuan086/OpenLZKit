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

variable "cur_buckets" {
  description = "Optional S3 buckets for Cost and Usage Reports, keyed by stable identifier."
  type = map(object({
    name          = string
    force_destroy = optional(bool, false)
    tags          = optional(map(string), {})
  }))
  default = {}
}

variable "cur_reports" {
  description = "Cost and Usage Report definitions keyed by stable identifier."
  type = map(object({
    report_name                = string
    time_unit                  = optional(string, "DAILY")
    format                     = optional(string, "Parquet")
    compression                = optional(string, "Parquet")
    additional_schema_elements = optional(list(string), ["RESOURCES"])
    additional_artifacts       = optional(list(string), ["ATHENA"])
    s3_bucket_key              = optional(string, null)
    s3_bucket_name             = optional(string, null)
    s3_prefix                  = optional(string, "cur")
    s3_region                  = optional(string, "us-east-1")
    refresh_closed_reports     = optional(bool, true)
    report_versioning          = optional(string, "OVERWRITE_REPORT")
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, report in var.cur_reports :
      report.s3_bucket_key != null || report.s3_bucket_name != null
    ])
    error_message = "Each CUR report must set either s3_bucket_key or s3_bucket_name."
  }

  validation {
    condition = alltrue([
      for _, report in var.cur_reports :
      report.s3_bucket_key == null ? true : contains(keys(var.cur_buckets), report.s3_bucket_key)
    ])
    error_message = "Each CUR report s3_bucket_key must exist in var.cur_buckets."
  }
}

variable "common_tags" {
  description = "Tags merged onto FinOps resources that support tagging."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
