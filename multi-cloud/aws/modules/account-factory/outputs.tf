output "account_ids" {
  description = "Map of account key to AWS account id."
  value       = { for k, account in aws_organizations_account.this : k => account.id }
}

output "account_arns" {
  description = "Map of account key to AWS account ARN."
  value       = { for k, account in aws_organizations_account.this : k => account.arn }
}
