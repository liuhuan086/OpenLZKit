variable "region" {
  description = "AWS region for log archive resources."
  type        = string
  default     = "us-east-1"
}

variable "log_bucket_name" {
  description = "Central log archive S3 bucket name."
  type        = string
}

variable "create_log_bucket" {
  description = "Create the central log archive S3 bucket."
  type        = bool
  default     = true
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
