variable "region" {
  description = "AWS region for FinOps resources."
  type        = string
  default     = "us-east-1"
}

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
}

variable "quicksight_athena_data_sources" {
  description = "QuickSight Athena data sources for FinOps reporting, keyed by stable identifier."
  type = map(object({
    data_source_id = string
    name           = string
    work_group     = optional(string, null)
    role_arn       = optional(string, null)
    permissions = optional(list(object({
      principal = string
      actions   = list(string)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "quicksight_folders" {
  description = "QuickSight folders for FinOps reporting assets, keyed by stable identifier."
  type = map(object({
    folder_id         = string
    name              = optional(string, null)
    folder_type       = optional(string, null)
    parent_folder_arn = optional(string, null)
    permissions = optional(list(object({
      principal = string
      actions   = list(string)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "quicksight_groups" {
  description = "QuickSight groups for FinOps reporting access, keyed by stable identifier."
  type = map(object({
    group_name  = string
    namespace   = optional(string, "default")
    description = optional(string, "")
  }))
  default = {}
}

variable "common_tags" {
  description = "Tags merged onto FinOps resources that support tagging."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
