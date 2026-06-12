output "permission_set_arns" {
  description = "Permission set ARNs by key."
  value       = module.identity_center.permission_set_arns
}

output "group_ids" {
  description = "Identity Store group ids by key."
  value       = module.identity_center.group_ids
}
