variable "region" {
  description = "AWS region for bootstrap resources."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Optional S3 bucket name for Terraform remote state."
  type        = string
  default     = null

  validation {
    condition     = var.state_bucket_name == null ? true : var.state_bucket_name != ""
    error_message = "state_bucket_name must be null or a non-empty string."
  }
}

variable "state_bucket_force_destroy" {
  description = "Whether the state bucket can be force destroyed. Keep false for production."
  type        = bool
  default     = false
}

variable "lock_table_name" {
  description = "Optional DynamoDB table name for Terraform state locking."
  type        = string
  default     = null

  validation {
    condition     = var.lock_table_name == null ? true : var.lock_table_name != ""
    error_message = "lock_table_name must be null or a non-empty string."
  }
}

variable "create_kms_key" {
  description = "Whether to create a customer managed KMS key for state bucket encryption."
  type        = bool
  default     = true
}

variable "kms_key_deletion_window_in_days" {
  description = "KMS key deletion window in days."
  type        = number
  default     = 30
}

variable "ci_cd_role_name" {
  description = "Optional IAM role name for CI/CD bootstrap access."
  type        = string
  default     = null

  validation {
    condition     = var.ci_cd_role_name == null ? true : var.ci_cd_role_name != ""
    error_message = "ci_cd_role_name must be null or a non-empty string."
  }
}

variable "ci_cd_trusted_principal_arns" {
  description = "AWS principals trusted to assume the optional CI/CD bootstrap role."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for principal in var.ci_cd_trusted_principal_arns : principal != "*"])
    error_message = "CI/CD trusted principals must not contain wildcard principals."
  }
}

variable "ci_cd_managed_policy_arns" {
  description = "Managed policies attached to the optional CI/CD bootstrap role."
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Tags merged onto bootstrap resources that support tagging."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
