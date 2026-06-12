variable "create_log_bucket" {
  description = "Create the central log archive S3 bucket."
  type        = bool
  default     = true
}

variable "log_bucket_name" {
  description = "Central log archive S3 bucket name. Required when create_log_bucket is true or CloudTrail writes to an existing bucket."
  type        = string
}

variable "object_lock_enabled" {
  description = "Enable S3 Object Lock on the created log bucket."
  type        = bool
  default     = true
}

variable "object_lock_retention_days" {
  description = "Default governance retention period in days for S3 Object Lock."
  type        = number
  default     = 365
}

variable "force_destroy" {
  description = "Allow Terraform to destroy non-empty log buckets. Keep false in production."
  type        = bool
  default     = false
}

variable "create_kms_key" {
  description = "Create a KMS key for log encryption."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Existing KMS key ARN when create_kms_key is false."
  type        = string
  default     = null
}

variable "kms_alias_name" {
  description = "KMS alias name for the created key."
  type        = string
  default     = "alias/openlzkit-log-archive"
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch log group for CloudTrail delivery."
  type        = string
  default     = "/aws/openlzkit/cloudtrail"
}

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 365
}

variable "cloudtrail" {
  description = "Organization CloudTrail configuration."
  type = object({
    name                          = string
    s3_key_prefix                 = optional(string, "cloudtrail")
    include_global_service_events = optional(bool, true)
    is_multi_region_trail         = optional(bool, true)
    is_organization_trail         = optional(bool, true)
    enable_log_file_validation    = optional(bool, true)
    cloud_watch_logs_role_arn     = optional(string, null)
    enable_logging                = optional(bool, true)
    tags                          = optional(map(string), {})
  })
  default = {
    name = "organization"
  }
}

variable "event_selectors" {
  description = "CloudTrail event selectors."
  type = list(object({
    read_write_type           = optional(string, "All")
    include_management_events = optional(bool, true)
    data_resources = optional(list(object({
      type   = string
      values = list(string)
    })), [])
  }))
  default = []
}

variable "common_tags" {
  description = "Tags merged onto created logging resources."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
