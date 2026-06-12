variable "region" {
  description = "Alibaba Cloud region for the provider. Resource Directory is global, but the provider still requires a region."
  type        = string
  default     = "cn-hangzhou"
}

provider "alicloud" {
  region = var.region
}

module "accounts" {
  source = "../../modules/account-factory"

  name_prefix = "lz-"

  folder_ids = {
    "workloads/dev" = "fd-example-workloads-dev"
  }

  accounts = {
    payment_dev = {
      display_name = "Payment Dev"
      folder_key   = "workloads/dev"
      tags = {
        owner               = "payments-platform"
        cost_center         = "cc-1001"
        env                 = "dev"
        project             = "payment"
        data_classification = "internal"
      }
    }
  }
}

output "account_ids" {
  description = "Created account ids by key."
  value       = module.accounts.account_ids
}
