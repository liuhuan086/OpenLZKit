variable "region" {
  description = "Alibaba Cloud region for the provider. Resource Directory is global, but the provider still requires a region."
  type        = string
  default     = "cn-hangzhou"
}

provider "alicloud" {
  region = var.region
}

# Minimal Landing Zone folder hierarchy, mirroring docs/design/06.
# Accounts are intentionally omitted here (billing impact); see the module README.
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

output "folder_ids" {
  description = "Created folder ids by key."
  value       = module.org.folder_ids
}
