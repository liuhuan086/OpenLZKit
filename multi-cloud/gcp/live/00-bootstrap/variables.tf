variable "project_id" {
  description = "Seed/platform project id hosting the Terraform state bucket and CI identity."
  type        = string
}

variable "region" {
  description = "Default region for the provider."
  type        = string
  default     = "us-central1"
}

variable "location" {
  description = "Location for the state bucket (region or multi-region, e.g. \"US\")."
  type        = string
  default     = "US"
}

variable "name_prefix" {
  description = "Prefix applied to created identity ids."
  type        = string
  default     = "lz-"
}

variable "state_bucket_name" {
  description = "Globally-unique GCS bucket name for remote Terraform state."
  type        = string
}

variable "github_owner" {
  description = "GitHub org/user allowed to impersonate the CI identity via OIDC."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository allowed to impersonate the CI identity via OIDC."
  type        = string
}

variable "pool_id" {
  description = "Workload Identity Pool id."
  type        = string
  default     = "github-pool"
}

variable "provider_id" {
  description = "Workload Identity Pool provider id."
  type        = string
  default     = "github"
}

variable "labels" {
  description = "Labels applied to the state bucket."
  type        = map(string)
  default     = {}
}
