variable "organization" {
  description = "Organization id (numeric) for Security Command Center exports/notifications."
  type        = string
}

variable "bigquery_exports" {
  description = <<-EOT
    SCC findings exports to BigQuery, keyed by stable id. `dataset` is a full
    dataset id ("projects/<p>/datasets/<d>"). `filter` narrows findings.
  EOT
  type = map(object({
    export_id   = string
    dataset     = string
    description = optional(string, "")
    filter      = optional(string, "state=\"ACTIVE\"")
  }))
  default = {}
}

variable "notification_configs" {
  description = <<-EOT
    SCC notification configs, keyed by stable id. `pubsub_topic` is a full topic id
    ("projects/<p>/topics/<t>"). `filter` selects findings to publish.
  EOT
  type = map(object({
    config_id    = string
    pubsub_topic = string
    description  = optional(string, "")
    filter       = optional(string, "state=\"ACTIVE\"")
  }))
  default = {}
}
