output "account_alias" {
  description = "Configured account alias."
  value       = module.identity.account_alias
}

output "permission_boundary_arns" {
  description = "Permission boundary policy ARNs by key."
  value       = module.identity.permission_boundary_arns
}

output "managed_policy_arns" {
  description = "Customer managed policy ARNs by key."
  value       = module.identity.managed_policy_arns
}
