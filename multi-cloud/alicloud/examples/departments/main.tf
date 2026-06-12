variable "region" {
  description = "Alibaba Cloud region for the provider. Resource Directory is global, but the provider still requires a region."
  type        = string
  default     = "cn-hangzhou"
}

provider "alicloud" {
  region = var.region
}

module "departments" {
  source = "../../modules/department"

  name_prefix      = "lz-"
  parent_folder_id = "fd-example-workloads"

  departments = {
    payments = {
      display_name       = "Payments"
      owner              = "payments-platform"
      cost_center        = "cc-1001"
      trusted_principals = ["acs:ram::1234567890123456:root"]
      system_policies    = ["ReadOnlyAccess"]
      control_policy_ids = ["cp-example-deny-disable-audit"]
      envs               = ["dev", "staging", "prod"]
    }
  }
}

output "department_folder_ids" {
  description = "Created department folder ids by key."
  value       = module.departments.folder_ids
}

output "department_role_arns" {
  description = "Created department role ARNs by key."
  value       = module.departments.role_arns
}
