variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

variable "parent_folder_id" {
  description = "Resource Directory folder id under which department folders are created, usually the Workloads folder from 10-org."
  type        = string
}

variable "departments" {
  description = "Business departments to create. Empty by default to avoid accidental organization changes."
  type = map(object({
    display_name               = string
    owner                      = string
    cost_center                = string
    trusted_principals         = list(string)
    system_policies            = optional(list(string), ["ReadOnlyAccess"])
    control_policy_ids         = optional(list(string), [])
    envs                       = optional(list(string), ["dev", "staging", "prod"])
    data_classification_values = optional(list(string), ["internal", "confidential"])
    tags                       = optional(map(string), {})
  }))
  default = {}
}

provider "alicloud" {
  region = var.region
}

# 15-departments: business-unit boundaries. Creates department folders, scoped
# department roles, department tag policies and optional control-policy attachments.
module "departments" {
  source = "../../modules/department"

  name_prefix      = "lz-"
  parent_folder_id = var.parent_folder_id
  departments      = var.departments
}

output "department_folder_ids" {
  description = "Department folder ids by key."
  value       = module.departments.folder_ids
}

output "department_role_arns" {
  description = "Department admin role ARNs by key."
  value       = module.departments.role_arns
}

output "department_standard_tags" {
  description = "Standard FinOps tags for downstream account/workload vending."
  value       = module.departments.standard_tags
}
