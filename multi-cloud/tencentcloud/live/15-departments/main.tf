variable "region" {
  description = "Tencent Cloud region for the provider."
  type        = string
  default     = "ap-guangzhou"
}

variable "parent_node_id" {
  description = "Parent organization node id (e.g. the Workloads node) for department nodes."
  type        = number
}

variable "management_uin" {
  description = "Root UIN allowed to assume department admin roles."
  type        = string
}

variable "departments" {
  description = "Business departments. manage_policy_id is environment-specific."
  type = map(object({
    name              = string
    create_admin_role = optional(bool, true)
    manage_policy_id  = optional(number)
  }))
  default = {
    engineering = { name = "Engineering" }
    finance     = { name = "Finance" }
  }
}

provider "tencentcloud" {
  region = var.region
}

# 15-departments: one organization node per business department, each with its
# own admin role and optional manage-policy attachment.
module "departments" {
  source         = "../../modules/department"
  name_prefix    = "lz-"
  parent_node_id = var.parent_node_id
  management_uin = var.management_uin
  departments    = var.departments
}

output "department_node_ids" {
  value = module.departments.node_ids
}
