module "org_policies" {
  source = "../../modules/org-policies"

  name_prefix = "lz-"

  policies = {
    deny_disable_audit = {
      name        = "deny-disable-audit"
      description = "Deny disabling organization audit and detective controls."
      type        = "SERVICE_CONTROL_POLICY"
      content = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Sid    = "DenyDisableAuditControls"
          Effect = "Deny"
          Action = [
            "cloudtrail:DeleteTrail",
            "cloudtrail:StopLogging",
            "config:DeleteConfigurationRecorder",
            "config:StopConfigurationRecorder",
            "guardduty:DeleteDetector",
            "securityhub:DisableSecurityHub",
          ]
          Resource = "*"
        }]
      })
    }

    required_tags = {
      name        = "required-tags"
      description = "Standardize mandatory enterprise tag keys."
      type        = "TAG_POLICY"
      content = jsonencode({
        tags = {
          owner = {
            tag_key = { "@@assign" = "owner" }
          }
          cost_center = {
            tag_key = { "@@assign" = "cost_center" }
          }
          env = {
            tag_key   = { "@@assign" = "env" }
            tag_value = { "@@assign" = ["prod", "nonprod", "dev", "test", "sandbox", "shared"] }
          }
          project = {
            tag_key = { "@@assign" = "project" }
          }
          data_classification = {
            tag_key   = { "@@assign" = "data_classification" }
            tag_value = { "@@assign" = ["public", "internal", "confidential", "restricted"] }
          }
        }
      })
    }
  }

  attachments = {
    root_audit = {
      policy_key = "deny_disable_audit"
      target_id  = "r-example"
    }
    root_tags = {
      policy_key = "required_tags"
      target_id  = "r-example"
    }
  }
}
