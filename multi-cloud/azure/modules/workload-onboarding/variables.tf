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

variable "location" {
  description = "Azure region for the workload resource group."
  type        = string
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

variable "admin_principal_id" {
  description = "Entra group object id for the workload team (gets admin_role on the resource group). Null skips."
  type        = string
  default     = null
}

variable "admin_role" {
  description = "Built-in role granted to the workload team on its resource group."
  type        = string
  default     = "Contributor"
}

variable "extra_tags" {
  description = "Additional tags merged onto the standard FinOps tag set."
  type        = map(string)
  default     = {}
}
