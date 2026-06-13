variable "name_prefix" {
  description = "Prefix applied to created resource names."
  type        = string
  default     = "lz-"
}

variable "project" {
  description = "Workload project id where the service account and IAM live."
  type        = string
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
  description = "Owning team (FinOps owner label)."
  type        = string
}

variable "cost_center" {
  description = "Cost center (FinOps cost_center label)."
  type        = string
}

variable "data_classification" {
  description = "Data classification label."
  type        = string
  default     = "internal"
}

variable "team_member" {
  description = "Cloud Identity group for the workload team (gets team_role on the project). Null skips."
  type        = string
  default     = null
}

variable "team_role" {
  description = "Role granted to the workload team on the project."
  type        = string
  default     = "roles/editor"
}

variable "extra_labels" {
  description = "Additional labels merged onto the standard FinOps label set."
  type        = map(string)
  default     = {}
}
