output "state_bucket_name" {
  description = "Terraform state bucket name, if created."
  value       = try(aws_s3_bucket.state[0].bucket, null)
}

output "state_bucket_arn" {
  description = "Terraform state bucket ARN, if created."
  value       = try(aws_s3_bucket.state[0].arn, null)
}

output "lock_table_name" {
  description = "Terraform state lock table name, if created."
  value       = try(aws_dynamodb_table.lock[0].name, null)
}

output "kms_key_arn" {
  description = "Terraform state KMS key ARN, if created."
  value       = try(aws_kms_key.state[0].arn, null)
}

output "ci_cd_role_arn" {
  description = "CI/CD bootstrap role ARN, if created."
  value       = try(aws_iam_role.ci_cd[0].arn, null)
}
