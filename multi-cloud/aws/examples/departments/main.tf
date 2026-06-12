module "departments" {
  source = "../../modules/department"

  name_prefix  = "lz-"
  parent_ou_id = "ou-example-workloads"

  departments = {
    payments = {
      display_name           = "Payments"
      owner                  = "payments-platform"
      cost_center            = "cc-1001"
      trusted_principal_arns = ["arn:aws:iam::111122223333:role/platform-admin"]
      managed_policy_arns    = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      organization_policy_ids = [
        "p-example-deny-disable-audit",
      ]
      envs = ["dev", "staging", "prod"]
    }

    data_platform = {
      display_name           = "Data Platform"
      owner                  = "data-platform"
      cost_center            = "cc-2001"
      trusted_principal_arns = ["arn:aws:iam::111122223333:role/platform-admin"]
      managed_policy_arns    = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      organization_policy_ids = [
        "p-example-required-tags",
      ]
      envs                       = ["dev", "prod"]
      data_classification_values = ["internal", "confidential", "restricted"]
    }
  }
}
