variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

provider "alicloud" {
  region = var.region
}

# 10-org: organization layer. Builds the Resource Directory folder hierarchy.
# Member-account creation is left disabled here; enable deliberately once
# billing and approval flows are in place.
module "org" {
  source = "../../modules/org"

  name_prefix = "lz-"

  folders = {
    security = {
      display_name = "Security"
      children = {
        audit-log      = { display_name = "Audit Log" }
        security-tools = { display_name = "Security Tooling" }
      }
    }
    infrastructure = {
      display_name = "Infrastructure"
      children = {
        network         = { display_name = "Network" }
        shared-services = { display_name = "Shared Services" }
      }
    }
    workloads = {
      display_name = "Workloads"
      children = {
        prod = { display_name = "Prod" }
        dev  = { display_name = "Dev" }
      }
    }
    sandbox = {
      display_name = "Sandbox"
    }
  }
}

output "root_folder_id" {
  description = "Resource Directory root folder id."
  value       = module.org.root_folder_id
}

output "folder_ids" {
  description = "Created folder ids by key."
  value       = module.org.folder_ids
}
