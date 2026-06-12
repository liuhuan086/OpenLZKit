output "role_arns" {
  description = "Cross-account IAM role ARNs by key."
  value       = module.cross_account_access.role_arns
}

output "resource_share_arns" {
  description = "AWS RAM resource share ARNs by key."
  value       = module.cross_account_access.resource_share_arns
}
