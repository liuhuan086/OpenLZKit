variable "name_prefix" {
  description = "Prefix applied to logging resource names."
  type        = string
  default     = "lz-"
}

variable "project" {
  description = "Logging project that owns the log-archive bucket."
  type        = string
}

variable "log_bucket_name" {
  description = "Globally-unique GCS bucket name for the central log archive."
  type        = string
}

variable "location" {
  description = "Location for the log-archive bucket."
  type        = string
  default     = "US"
}

variable "retention_days" {
  description = "Log retention in days (bucket retention policy)."
  type        = number
  default     = 365
}

variable "lock_retention" {
  description = "Lock the retention policy (Bucket Lock). IRREVERSIBLE: the policy can no longer be removed or shortened and the bucket cannot be deleted. Enable in production for immutable audit logs."
  type        = bool
  default     = false
}

variable "sinks" {
  description = <<-EOT
    Aggregated log sinks keyed by stable id. `parent` is a folder/org resource id
    ("folders/<id>" or "organizations/<id>"); logs matching `filter` are routed to
    the log-archive bucket. Empty by default.
  EOT
  type = map(object({
    parent           = string
    filter           = optional(string, "")
    include_children = optional(bool, true)
  }))
  default = {}
}
