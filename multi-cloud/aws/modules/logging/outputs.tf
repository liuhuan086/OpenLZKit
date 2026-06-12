output "log_bucket_name" {
  description = "Central log archive bucket name."
  value       = local.bucket_id
}

output "kms_key_arn" {
  description = "KMS key ARN used for log encryption."
  value       = local.kms_key_arn
}

output "cloudtrail_arn" {
  description = "Organization CloudTrail ARN."
  value       = aws_cloudtrail.organization.arn
}

output "cloudwatch_log_group_name" {
  description = "CloudTrail CloudWatch log group name."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}
