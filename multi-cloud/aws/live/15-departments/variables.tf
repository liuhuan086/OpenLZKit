variable "region" {
  description = "AWS region for provider configuration."
  type        = string
  default     = "us-east-1"
}

variable "workloads_parent_ou_id" {
  description = "Parent OU id for business department OUs, usually module.org.ou_ids[\"workloads\"]."
  type        = string
}

variable "departments" {
  description = "Reviewed business departments to create under the workloads parent OU."
  type = map(object({
    display_name               = string
    owner                      = string
    cost_center                = string
    trusted_principal_arns     = list(string)
    managed_policy_arns        = optional(list(string), ["arn:aws:iam::aws:policy/ReadOnlyAccess"])
    organization_policy_ids    = optional(list(string), [])
    envs                       = optional(list(string), ["dev", "staging", "prod"])
    data_classification_values = optional(list(string), ["internal", "confidential"])
    tags                       = optional(map(string), {})
  }))
  default = {}
}
