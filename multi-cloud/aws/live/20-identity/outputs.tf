output "account_alias" {
  description = "Configured account alias."
  value       = module.identity.account_alias
}

output "password_policy_managed" {
  description = "Whether the account password policy is managed."
  value       = module.identity.password_policy_managed
}

output "permission_boundary_arns" {
  description = "Permission boundary policy ARNs by key."
  value       = module.identity.permission_boundary_arns
}

output "managed_policy_arns" {
  description = "Customer managed policy ARNs by key."
  value       = module.identity.managed_policy_arns
}
