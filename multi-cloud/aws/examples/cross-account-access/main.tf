module "cross_account_access" {
  source = "../../modules/cross-account-access"

  name_prefix = "lz-"

  oidc_providers = {
    github_actions = {
      url             = "https://token.actions.githubusercontent.com"
      client_id_list  = ["sts.amazonaws.com"]
      thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
    }
  }

  access_roles = {
    security_audit = {
      role_name                = "security-audit"
      description              = "Read-only audit role for the security tooling account."
      trusted_principal_arns   = ["arn:aws:iam::111122223333:root"]
      federated_principal_arns = []
      oidc_provider_keys       = []
      external_id              = "security-audit"
      condition                = {}
      oidc_condition           = {}
      managed_policy_arns      = ["arn:aws:iam::aws:policy/SecurityAudit"]
      inline_policies          = tomap({})
    }

    workload_deploy = {
      role_name                = "workload-deploy"
      description              = "OIDC deploy role for reviewed CI/CD workflows."
      trusted_principal_arns   = []
      federated_principal_arns = []
      oidc_provider_keys       = ["github_actions"]
      external_id              = null
      condition                = {}
      managed_policy_arns      = []
      oidc_condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:example-org/example-repo:*"
        }
      }
      inline_policies = {
        deploy = jsonencode({
          Version = "2012-10-17"
          Statement = [{
            Effect = "Allow"
            Action = [
              "cloudformation:DescribeStacks",
              "cloudformation:CreateChangeSet",
              "cloudformation:ExecuteChangeSet",
            ]
            Resource = "*"
          }]
        })
      }
    }
  }

  resource_shares = {
    shared_tgw = {
      name                      = "shared-tgw"
      allow_external_principals = false
      principals                = ["222233334444"]
      resource_arns             = ["arn:aws:ec2:us-east-1:111122223333:transit-gateway/tgw-0123456789abcdef0"]
    }
  }
}
