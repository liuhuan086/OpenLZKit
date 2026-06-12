output "ou_ids" {
  description = "Created department OU ids by key."
  value       = { for key, ou in aws_organizations_organizational_unit.department : key => ou.id }
}

output "role_names" {
  description = "Department administrator IAM role names by key."
  value       = { for key, role in aws_iam_role.department_admin : key => role.name }
}

output "role_arns" {
  description = "Department administrator IAM role ARNs by key."
  value       = { for key, role in aws_iam_role.department_admin : key => role.arn }
}

output "tag_policy_ids" {
  description = "Department Tag Policy ids by key."
  value       = { for key, policy in aws_organizations_policy.department_tags : key => policy.id }
}

output "standard_tags" {
  description = "Standard department tag set by key."
  value       = local.department_tags
}
