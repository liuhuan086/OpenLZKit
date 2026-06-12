variable "region" {
  description = "AWS region for workload onboarding resources."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix applied to workload role and metadata names."
  type        = string
  default     = ""
}

variable "parameter_prefix" {
  description = "SSM Parameter Store prefix for workload onboarding metadata."
  type        = string
  default     = "/openlzkit/workloads"
}

variable "create_metadata_parameters" {
  description = "Whether to write workload onboarding metadata into SSM Parameter Store."
  type        = bool
  default     = true
}

variable "max_session_duration" {
  description = "Max assume-role session duration in seconds."
  type        = number
  default     = 3600
}

variable "workloads" {
  description = "Workload onboarding contracts keyed by stable identifier."
  type = map(object({
    name                   = string
    description            = optional(string, "")
    department             = string
    owner                  = string
    cost_center            = string
    env                    = string
    project                = string
    data_classification    = optional(string, "internal")
    account_id             = optional(string, "")
    vpc_id                 = optional(string, "")
    subnet_ids             = optional(list(string), [])
    permission_set_names   = optional(list(string), [])
    trusted_principal_arns = optional(list(string), [])
    external_id            = optional(string, null)
    condition              = optional(any, null)
    managed_policy_arns    = optional(list(string), [])
    inline_policies        = optional(map(string), {})
    additional_metadata    = optional(map(string), {})
    tags                   = optional(map(string), {})
  }))
  default = {}
}

variable "common_tags" {
  description = "Tags merged onto created workload roles and metadata parameters."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
