output "account_alias" {
  description = "Configured IAM account alias, if managed."
  value       = try(aws_iam_account_alias.this[0].account_alias, null)
}

output "password_policy_managed" {
  description = "Whether the account password policy is managed by this module."
  value       = var.create_account_password_policy
}

output "permission_boundary_arns" {
  description = "Permission boundary policy ARNs by key."
  value       = { for key, policy in aws_iam_policy.permission_boundary : key => policy.arn }
}

output "managed_policy_arns" {
  description = "Customer managed policy ARNs by key."
  value       = { for key, policy in aws_iam_policy.managed : key => policy.arn }
}
