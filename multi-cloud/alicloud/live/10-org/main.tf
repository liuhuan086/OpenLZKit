variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

variable "accounts" {
  description = "Optional member accounts to create through the account factory. Empty by default because account creation has billing impact."
  type = map(object({
    display_name = string
    folder_key   = string
    tags         = optional(map(string), {})
  }))
  default = {}
}

variable "account_common_tags" {
  description = "Tags merged onto every account created by the account factory."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}

provider "alicloud" {
  region = var.region
}

# 10-org: organization layer. Builds the Resource Directory folder hierarchy.
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

# Account vending is wired here but disabled by default. Enable only after
# billing, ownership and account naming approvals are complete.
module "accounts" {
  source = "../../modules/account-factory"

  name_prefix = "lz-"
  folder_ids  = module.org.folder_ids
  accounts    = var.accounts
  common_tags = var.account_common_tags
}

output "root_folder_id" {
  description = "Resource Directory root folder id."
  value       = module.org.root_folder_id
}

output "folder_ids" {
  description = "Created folder ids by key."
  value       = module.org.folder_ids
}

output "account_ids" {
  description = "Created member account ids by key."
  value       = module.accounts.account_ids
}
