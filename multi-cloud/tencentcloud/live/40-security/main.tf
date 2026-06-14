variable "region" {
  description = "Tencent Cloud region for the provider."
  type        = string
  default     = "ap-guangzhou"
}

variable "root_node_id" {
  description = "Organization root node id to attach guardrail policies to."
  type        = number
}

provider "tencentcloud" {
  region = var.region
}

# 40-security: organization guardrails as manage policies (deny high-risk ops).
module "control_policies" {
  source      = "../../modules/control-policies"
  name_prefix = "lz-"

  policies = {
    deny-disable-audit = {
      description = "Deny disabling CloudAudit and deleting audit tracks."
      content = jsonencode({
        version = "2.0"
        statement = [{
          effect   = "deny"
          action   = ["cloudaudit:DeleteAuditTrack", "cloudaudit:UpdateAuditTrack", "cloudaudit:DeleteAudit"]
          resource = ["*"]
        }]
      })
    }
    deny-leave-organization = {
      description = "Deny member accounts quitting the organization."
      content = jsonencode({
        version = "2.0"
        statement = [{
          effect   = "deny"
          action   = ["organization:QuitOrganization"]
          resource = ["*"]
        }]
      })
    }
  }

  attachments = {
    deny-disable-audit = {
      policy_key  = "deny-disable-audit"
      target_id   = var.root_node_id
      target_type = "NODE"
    }
    deny-leave-organization = {
      policy_key  = "deny-leave-organization"
      target_id   = var.root_node_id
      target_type = "NODE"
    }
  }
}

output "policy_ids" {
  value = module.control_policies.policy_ids
}
