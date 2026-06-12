variable "subscription_id" {
  description = "Azure subscription id for the provider."
  type        = string
}

variable "parent_management_group_id" {
  description = "Parent management group (e.g. the Landing Zones group) for department groups."
  type        = string
}

variable "departments" {
  description = "Business departments. admin_principal_id / budgets are environment-specific."
  type = map(object({
    display_name          = string
    admin_principal_id    = optional(string)
    admin_role            = optional(string, "Contributor")
    admin_principal_type  = optional(string, "Group")
    budget_amount         = optional(number)
    budget_start_date     = optional(string)
    budget_contact_emails = optional(list(string), [])
  }))
  default = {
    engineering = { display_name = "Engineering" }
    finance     = { display_name = "Finance" }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# 15-departments: one management group per business department, each with its own
# admin RBAC scope and budget. Mirrors the org hierarchy under Landing Zones.
module "departments" {
  source = "../../modules/department"

  name_prefix                = "lz-"
  parent_management_group_id = var.parent_management_group_id
  departments                = var.departments
}

output "department_management_group_ids" {
  value = module.departments.management_group_ids
}
