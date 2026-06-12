module "workload_onboarding" {
  source = "../../modules/workload-onboarding"

  name_prefix      = "lz-"
  parameter_prefix = "/openlzkit/examples/workloads"

  workloads = {
    payments_api = {
      name                = "payments-api"
      description         = "Payments API production workload onboarding contract."
      department          = "payments"
      owner               = "payments-platform@example.invalid"
      cost_center         = "cc-4200"
      env                 = "prod"
      project             = "payments-api"
      data_classification = "confidential"
      account_id          = "111122223333"
      vpc_id              = "vpc-0123456789abcdef0"
      subnet_ids          = ["subnet-0123456789abcdef0", "subnet-abcdef01234567890"]
      permission_set_names = [
        "PaymentsReadOnly",
        "PaymentsBreakGlass",
      ]
      trusted_principal_arns = [
        "arn:aws:iam::444455556666:role/platform-deployment",
      ]
      external_id = "payments-api-prod"
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess",
      ]
      inline_policies = {
        workload_metadata_read = jsonencode({
          Version = "2012-10-17"
          Statement = [{
            Effect = "Allow"
            Action = [
              "ssm:GetParameter",
              "ssm:GetParameters",
            ]
            Resource = "arn:aws:ssm:*:*:parameter/openlzkit/examples/workloads/payments_api/*"
          }]
        })
      }
      additional_metadata = {
        service_tier     = "tier-1"
        recovery_profile = "multi-az"
      }
      tags = {
        business_service = "payments"
      }
    }
  }
}
