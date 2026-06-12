variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

variable "trusted_account_id" {
  description = "Management account id whose principals may assume these roles (via SSO/federation)."
  type        = string
}

provider "alicloud" {
  region = var.region
}

locals {
  trusted = ["acs:ram::${var.trusted_account_id}:root"]
}

# 20-identity: standard org roles. People assume these via SSO; long-lived RAM
# users are not created. Policies are least-privilege starting points.
module "identity" {
  source = "../../modules/identity"

  name_prefix = "lz-"

  roles = {
    platform-admin = {
      description        = "Platform & shared infrastructure administration."
      trusted_principals = local.trusted
      system_policies    = ["AliyunVPCFullAccess", "AliyunECSFullAccess"]
    }
    security-auditor = {
      description        = "Read-only security & audit."
      trusted_principals = local.trusted
      system_policies    = ["ReadOnlyAccess", "AliyunActionTrailReadOnlyAccess"]
    }
    network-admin = {
      description        = "Network and connectivity administration."
      trusted_principals = local.trusted
      system_policies    = ["AliyunVPCFullAccess"]
    }
    app-developer = {
      description        = "Workload resources within assigned accounts."
      trusted_principals = local.trusted
      system_policies    = ["AliyunECSFullAccess"]
    }
    finance-viewer = {
      description        = "Read-only cost and billing."
      trusted_principals = local.trusted
      system_policies    = ["AliyunBSSReadOnlyAccess"]
    }
  }
}

output "role_arns" {
  description = "Created role ARNs by key."
  value       = module.identity.role_arns
}
