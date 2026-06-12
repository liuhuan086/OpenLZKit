variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

provider "alicloud" {
  region = var.region
}

module "cross_account_access" {
  source = "../../modules/cross-account-access"

  name_prefix = "lz-"

  access_roles = {
    security_audit = {
      role_name          = "security-audit"
      description        = "Read-only audit role for the security account."
      trusted_principals = ["acs:ram::1111222233334444:root"]
      system_policies    = ["SecurityAudit"]
      condition = {
        StringEquals = {
          "sts:ExternalId" = "security-audit"
        }
      }
    }
  }

  resource_shares = {
    shared_network = {
      name                   = "shared-network"
      allow_external_targets = false
      targets                = ["1111222233334444"]
      resource_arns          = ["acs:vpc:cn-hangzhou:5555666677778888:vpc/vpc-example"]
      permission_names       = ["AliyunRSDefaultPermissionVSwitch"]
    }
  }
}

output "role_arns" {
  description = "Created cross-account role ARNs by key."
  value       = module.cross_account_access.role_arns
}

output "resource_share_ids" {
  description = "Created Resource Share ids by key."
  value       = module.cross_account_access.resource_share_ids
}
