variable "subscription_id" {
  description = "Azure subscription id hosting the Terraform state and platform resources."
  type        = string
}

variable "location" {
  description = "Azure region for the state resource group and storage account."
  type        = string
  default     = "eastus"
}

variable "name_prefix" {
  description = "Prefix applied to created identity/display names."
  type        = string
  default     = "lz-"
}

variable "state_resource_group_name" {
  description = "Resource group holding the Terraform state storage account."
  type        = string
  default     = "lz-tfstate-rg"
}

variable "state_storage_account_name" {
  description = "Globally-unique storage account name for remote Terraform state (3-24 lowercase alphanumeric)."
  type        = string
}

variable "tfstate_container_name" {
  description = "Blob container holding state files."
  type        = string
  default     = "tfstate"
}

variable "github_owner" {
  description = "GitHub org/user allowed to assume the CI identity via OIDC."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository allowed to assume the CI identity via OIDC."
  type        = string
}

variable "ci_role_definition_name" {
  description = "Built-in role granted to the CI identity. Reader for plan-only pipelines."
  type        = string
  default     = "Reader"
}

variable "ci_role_scope" {
  description = "ARM scope (subscription or management group id) for the CI role assignment. Null skips the assignment."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to the resource group and storage account."
  type        = map(string)
  default     = {}
}
