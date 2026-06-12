output "department_ou_ids" {
  description = "Created department OU ids by key."
  value       = module.departments.ou_ids
}

output "department_role_arns" {
  description = "Department administrator IAM role ARNs by key."
  value       = module.departments.role_arns
}
