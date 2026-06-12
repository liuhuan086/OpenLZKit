variable "name_prefix" {
  description = "Prefix applied to created resource names."
  type        = string
  default     = "lz-"
}

variable "workload_name" {
  description = "Short workload identifier, e.g. \"payment\"."
  type        = string
}

variable "env" {
  description = "Environment for this workload instance."
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod", "sandbox"], var.env)
    error_message = "env must be one of: dev, staging, prod, sandbox."
  }
}

variable "owner" {
  description = "Owning team (FinOps owner tag)."
  type        = string
}

variable "cost_center" {
  description = "Cost center (FinOps cost_center tag)."
  type        = string
}

variable "data_classification" {
  description = "Data classification tag."
  type        = string
  default     = "internal"
}

variable "trusted_principals" {
  description = "RAM principal ARNs allowed to assume the workload developer role."
  type        = list(string)
}

variable "extra_tags" {
  description = "Additional tags merged onto the standard FinOps tag set."
  type        = map(string)
  default     = {}
}
