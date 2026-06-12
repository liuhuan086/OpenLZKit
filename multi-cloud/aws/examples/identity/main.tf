module "identity" {
  source = "../../modules/identity"

  name_prefix                    = "lz-"
  account_alias                  = "example-payments-prod"
  create_account_password_policy = true

  permission_boundaries = {
    workload_operator = {
      name        = "workload-operator-boundary"
      description = "Boundary for workload operator roles."
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Deny"
            Action   = "iam:CreateAccessKey"
            Resource = "*"
          },
          {
            Effect   = "Allow"
            Action   = "*"
            Resource = "*"
          },
        ]
      })
      tags = {
        control = "permission-boundary"
      }
    }
  }

  managed_policies = {
    workload_metadata_read = {
      name        = "workload-metadata-read"
      description = "Read workload onboarding metadata."
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect = "Allow"
          Action = [
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:GetParametersByPath",
          ]
          Resource = "arn:aws:ssm:*:*:parameter/openlzkit/workloads/*"
        }]
      })
    }
  }
}
