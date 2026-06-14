variable "name_prefix" {
  description = "Prefix applied to logging resource names."
  type        = string
  default     = "lz-"
}

variable "region" {
  description = "Region of the CLS topic (used for the audit track storage)."
  type        = string
}

variable "logset_name" {
  description = "CLS logset name for the central audit log."
  type        = string
  default     = "central-audit"
}

variable "topic_name" {
  description = "CLS topic name for CloudAudit events."
  type        = string
  default     = "cloudaudit"
}

variable "period" {
  description = "CLS topic retention in days."
  type        = number
  default     = 365
}

variable "audit_action_type" {
  description = "CloudAudit track action type (Read or Write)."
  type        = string
  default     = "Write"
}

variable "track_for_all_members" {
  description = "Capture audit events for all organization members."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the logset/topic."
  type        = map(string)
  default     = {}
}
