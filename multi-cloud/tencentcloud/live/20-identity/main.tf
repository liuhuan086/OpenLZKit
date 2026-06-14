variable "region" {
  description = "Tencent Cloud region for the provider."
  type        = string
  default     = "ap-guangzhou"
}

variable "management_uin" {
  description = "Root UIN of the management account allowed to assume these roles."
  type        = string
}

provider "tencentcloud" {
  region = var.region
}

# 20-identity: least-privilege CAM roles for platform personas. Roles are assumed
# from the management account; long-lived sub-users are avoided.
module "identity" {
  source      = "../../modules/identity"
  name_prefix = "lz-"

  custom_policies = {
    security-readonly = {
      description = "Read-only access for security and audit."
      document = jsonencode({
        version = "2.0"
        statement = [{
          effect   = "allow"
          action   = ["cam:Get*", "cam:List*", "cloudaudit:Describe*", "monitor:Get*"]
          resource = ["*"]
        }]
      })
    }
  }

  roles = {
    security-auditor = {
      description        = "Security auditor role (read-only)."
      custom_policy_keys = ["security-readonly"]
      document = jsonencode({
        version = "2.0"
        statement = [{
          effect    = "allow"
          action    = ["name/sts:AssumeRole"]
          principal = { qcs = ["qcs::cam::uin/${var.management_uin}:root"] }
        }]
      })
    }
  }
}

output "role_ids" {
  value = module.identity.role_ids
}
