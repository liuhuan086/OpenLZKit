output "permission_set_arns" {
  description = "Permission set ARNs by key."
  value       = { for key, permission_set in aws_ssoadmin_permission_set.this : key => permission_set.arn }
}

output "group_ids" {
  description = "Identity Store group ids by key."
  value       = { for key, group in aws_identitystore_group.this : key => group.group_id }
}

output "user_ids" {
  description = "Identity Store user ids by key."
  value       = { for key, user in aws_identitystore_user.this : key => user.user_id }
}

output "assignment_ids" {
  description = "IAM Identity Center account assignment ids by key."
  value       = { for key, assignment in aws_ssoadmin_account_assignment.this : key => assignment.id }
}
