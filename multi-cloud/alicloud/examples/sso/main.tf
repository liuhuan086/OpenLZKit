variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

provider "alicloud" {
  region = var.region
}

module "sso" {
  source = "../../modules/sso"

  directory_name                = "lz-sso"
  allow_user_to_get_credentials = false

  groups = {
    platform_admins = {
      name        = "platform-admins"
      description = "Landing Zone platform administrators."
    }
    security_auditors = {
      name        = "security-auditors"
      description = "Security read-only audit group."
    }
  }

  access_configurations = {
    security_audit = {
      name             = "SecurityAudit"
      description      = "Read-only security audit access."
      session_duration = 3600
      permission_policies = [{
        name = "SecurityAudit"
        type = "System"
      }]
    }
  }

  assignments = {
    audit_to_prod = {
      access_configuration_key = "security_audit"
      principal_type           = "Group"
      group_key                = "security_auditors"
      target_id                = "1234567890123456"
      target_type              = "RD-Account"
    }
  }

  provisionings = {
    security_audit_prod = {
      access_configuration_key = "security_audit"
      target_id                = "1234567890123456"
      target_type              = "RD-Account"
    }
  }
}

output "directory_id" {
  description = "CloudSSO directory id."
  value       = module.sso.directory_id
}

output "access_configuration_ids" {
  description = "CloudSSO access configuration ids by key."
  value       = module.sso.access_configuration_ids
}
