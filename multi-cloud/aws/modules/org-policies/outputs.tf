output "policy_ids" {
  description = "Organizations policy ids by stable key."
  value       = { for key, policy in aws_organizations_policy.this : key => policy.id }
}

output "policy_arns" {
  description = "Organizations policy ARNs by stable key."
  value       = { for key, policy in aws_organizations_policy.this : key => policy.arn }
}

output "attachment_ids" {
  description = "Organizations policy attachment ids by stable key."
  value       = { for key, attachment in aws_organizations_policy_attachment.this : key => attachment.id }
}
