module "identity_center" {
  source = "../../modules/identity-center"

  instance_arn      = "arn:aws:sso:::instance/ssoins-1234567890abcdef"
  identity_store_id = "d-1234567890"

  groups = {
    security_auditors = {
      display_name = "Security Auditors"
      description  = "Read-only security audit users."
    }
  }

  permission_sets = {
    security_audit = {
      name                = "SecurityAudit"
      description         = "Read-only security audit access."
      session_duration    = "PT4H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/SecurityAudit"]
    }

    workload_readonly = {
      name                = "WorkloadReadOnly"
      description         = "Read-only workload account access."
      session_duration    = "PT4H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect = "Deny"
          Action = [
            "iam:CreateAccessKey",
            "iam:UpdateAccessKey",
          ]
          Resource = "*"
        }]
      })
    }
  }

  assignments = {
    security_audit_prod = {
      permission_set_key = "security_audit"
      principal_type     = "GROUP"
      principal_id       = "11111111-2222-3333-4444-555555555555"
      target_id          = "111122223333"
    }
  }
}
