variable "name_prefix" {
  description = "Prefix applied to logging resource names."
  type        = string
  default     = "lz-"
}

variable "resource_group_name" {
  description = "Resource group for the Log Analytics workspace."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "workspace_name" {
  description = "Log Analytics workspace name (central audit/log sink)."
  type        = string
}

variable "sku" {
  description = "Log Analytics SKU."
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Workspace data retention in days."
  type        = number
  default     = 365
}

variable "diagnostic_settings" {
  description = <<-EOT
    Diagnostic settings routing resource logs to the workspace, keyed by stable id.
    Empty by default because target resource ids are environment-specific.
  EOT
  type = map(object({
    target_resource_id  = string
    log_category_groups = optional(list(string), ["allLogs"])
    enable_metrics      = optional(bool, true)
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to the workspace."
  type        = map(string)
  default     = {}
}
