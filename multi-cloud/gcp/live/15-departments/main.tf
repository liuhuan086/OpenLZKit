variable "project_id" {
  description = "Project id for the provider."
  type        = string
}

variable "parent_folder" {
  description = "Parent folder for department folders (e.g. the Workloads folder, \"folders/<id>\")."
  type        = string
}

variable "billing_account" {
  description = "Billing account id for department budgets."
  type        = string
  default     = null
}

variable "departments" {
  description = "Business departments. admin_member / budgets are environment-specific."
  type = map(object({
    display_name       = string
    admin_member       = optional(string)
    admin_role         = optional(string, "roles/resourcemanager.folderAdmin")
    budget_units       = optional(number)
    threshold_percents = optional(list(number), [0.9])
  }))
  default = {
    engineering = { display_name = "Engineering" }
    finance     = { display_name = "Finance" }
  }
}

provider "google" {
  project = var.project_id
}

# 15-departments: one folder per business department, each with its own admin
# IAM scope and budget. Sits under the Workloads folder and inherits org policy.
module "departments" {
  source          = "../../modules/department"
  name_prefix     = "lz-"
  parent          = var.parent_folder
  billing_account = var.billing_account
  departments     = var.departments
}

output "department_folder_names" {
  value = module.departments.folder_names
}
