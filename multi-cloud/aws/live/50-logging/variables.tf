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

variable "firehose_streams" {
  description = "Kinesis Data Firehose streams that deliver operational logs to S3."
  type = map(object({
    name                       = string
    role_arn                   = string
    bucket_arn                 = optional(string, null)
    prefix                     = optional(string, "firehose/!{timestamp:yyyy/MM/dd}/")
    error_output_prefix        = optional(string, "firehose-errors/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}/")
    buffering_interval         = optional(number, 300)
    buffering_size             = optional(number, 5)
    compression_format         = optional(string, "GZIP")
    kms_key_arn                = optional(string, null)
    cloudwatch_log_group_name  = optional(string, null)
    cloudwatch_log_stream_name = optional(string, null)
    tags                       = optional(map(string), {})
  }))
  default = {}
}

variable "security_lake_data_lakes" {
  description = "Security Lake data lakes keyed by stable identifier."
  type = map(object({
    meta_store_manager_role_arn = string
    configurations = list(object({
      region               = string
      kms_key_id           = optional(string, null)
      expiration_days      = optional(number, null)
      transition_days      = optional(number, null)
      transition_class     = optional(string, null)
      replication_regions  = optional(list(string), [])
      replication_role_arn = optional(string, null)
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "security_lake_aws_log_sources" {
  description = "Security Lake AWS log sources keyed by stable identifier."
  type = map(object({
    source_name    = string
    source_version = optional(string, null)
    regions        = list(string)
    accounts       = optional(list(string), [])
  }))
  default = {}
}
