variable "region" {
  description = "Alibaba Cloud region for the OSS state bucket."
  type        = string
  default     = "cn-hangzhou"
}

variable "state_bucket_name" {
  description = "Globally-unique OSS bucket name for remote Terraform state."
  type        = string
}

variable "enable_resource_directory" {
  description = "Enable the Resource Directory on this (management) account. One-time, account-wide."
  type        = bool
  default     = true
}

variable "github_owner" {
  description = "GitHub org/user allowed to assume the CI/CD role via OIDC."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository allowed to assume the CI/CD role via OIDC."
  type        = string
}

variable "tags" {
  description = "Tags applied to taggable bootstrap resources."
  type        = map(string)
  default     = {}
}
