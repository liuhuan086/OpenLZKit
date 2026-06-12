variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

provider "alicloud" {
  region = var.region
}

module "delegation" {
  source = "../../modules/delegation"

  name_prefix = "lz-"

  delegated_administrators = {
    config = {
      account_id        = "1234567890123456"
      service_principal = "config.aliyuncs.com"
    }
    resource_share = {
      account_id        = "1234567890123456"
      service_principal = "resourcesharing.aliyuncs.com"
    }
  }

  cloud_sso_delegate_account_id = "1234567890123456"

  resource_shares = {
    shared_vswitch = {
      name                   = "shared-vswitch"
      allow_external_targets = false
      targets                = ["2345678901234567"]
      resource_arns          = ["acs:vpc:cn-hangzhou:1234567890123456:vswitch/vsw-example"]
      permission_names       = ["AliyunRSDefaultPermissionVSwitch"]
      tags = {
        owner       = "network-platform"
        cost_center = "cc-network"
      }
    }
  }
}

output "delegated_administrator_ids" {
  description = "Delegated administrator ids by key."
  value       = module.delegation.delegated_administrator_ids
}

output "resource_share_ids" {
  description = "Resource Share ids by key."
  value       = module.delegation.resource_share_ids
}
