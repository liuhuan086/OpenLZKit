variable "name_prefix" {
  description = "Prefix applied to logging resource names."
  type        = string
  default     = "lz-"
}

variable "region" {
  description = "Region of the SLS project (used to build the ActionTrail SLS ARN)."
  type        = string
}

variable "audit_project_name" {
  description = "SLS project name for central audit logs (globally unique)."
  type        = string
}

variable "audit_logstore_name" {
  description = "SLS logstore name for ActionTrail events."
  type        = string
  default     = "actiontrail"
}

variable "retention_period" {
  description = "Logstore retention in days."
  type        = number
  default     = 365
}

variable "is_organization_trail" {
  description = "Create an organization (multi-account) ActionTrail trail. Requires Resource Directory management account."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the SLS project."
  type        = map(string)
  default     = {}
}
