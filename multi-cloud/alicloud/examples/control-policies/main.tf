variable "region" {
  description = "Alibaba Cloud region for the provider. Resource Directory is global, but the provider still requires a region."
  type        = string
  default     = "cn-hangzhou"
}

provider "alicloud" {
  region = var.region
}

module "control_policies" {
  source = "../../modules/control-policies"

  name_prefix = "lz-"

  policies = {
    deny_disable_audit = {
      name         = "deny-disable-audit"
      description  = "Deny disabling organization audit controls."
      effect_scope = "RAM"
      policy_document = jsonencode({
        Version = "1"
        Statement = [{
          Effect   = "Deny"
          Action   = ["actiontrail:DeleteTrail", "actiontrail:StopLogging"]
          Resource = ["*"]
        }]
      })
    }
  }

  attachments = {
    root_audit_guardrail = {
      policy_key = "deny_disable_audit"
      target_id  = "fd-example-root"
    }
  }
}

output "policy_ids" {
  description = "Created control policy ids by key."
  value       = module.control_policies.policy_ids
}
