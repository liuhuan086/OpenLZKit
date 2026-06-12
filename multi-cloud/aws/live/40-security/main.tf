locals {
  org_policies = {
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

    deny_unapproved_regions = {
      name        = "deny-unapproved-regions"
      description = "Deny most actions outside approved workload regions."
      type        = "SERVICE_CONTROL_POLICY"
      content = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Sid    = "DenyUnapprovedRegions"
          Effect = "Deny"
          NotAction = [
            "a4b:*",
            "acm:*",
            "aws-marketplace-management:*",
            "aws-marketplace:*",
            "aws-portal:*",
            "budgets:*",
            "ce:*",
            "chime:*",
            "cloudfront:*",
            "config:*",
            "cur:*",
            "directconnect:*",
            "ec2:DescribeRegions",
            "globalaccelerator:*",
            "health:*",
            "iam:*",
            "importexport:*",
            "kms:*",
            "mobileanalytics:*",
            "networkmanager:*",
            "organizations:*",
            "pricing:*",
            "route53:*",
            "route53domains:*",
            "s3:GetAccountPublic*",
            "s3:ListAllMyBuckets",
            "s3:PutAccountPublic*",
            "shield:*",
            "sts:*",
            "support:*",
            "trustedadvisor:*",
            "waf-regional:*",
            "waf:*",
            "wafv2:*",
            "wellarchitected:*",
          ]
          Resource = "*"
          Condition = {
            StringNotEquals = {
              "aws:RequestedRegion" = var.allowed_regions
            }
          }
        }]
      })
    }

    required_tags = {
      name        = "required-tags"
      description = "Standardize mandatory enterprise tag keys."
      type        = "TAG_POLICY"
      content = jsonencode({
        tags = {
          owner               = { tag_key = { "@@assign" = "owner" } }
          cost_center         = { tag_key = { "@@assign" = "cost_center" } }
          project             = { tag_key = { "@@assign" = "project" } }
          data_classification = { tag_key = { "@@assign" = "data_classification" } }
          env = {
            tag_key   = { "@@assign" = "env" }
            tag_value = { "@@assign" = ["prod", "nonprod", "dev", "test", "sandbox", "shared"] }
          }
        }
      })
    }
  }
}

module "org_policies" {
  source = "../../modules/org-policies"

  name_prefix = "lz-"
  policies    = local.org_policies
  attachments = var.policy_attachments
}
