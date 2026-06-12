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

output "firehose_stream_arns" {
  description = "Firehose delivery stream ARNs by key."
  value       = { for key, stream in aws_kinesis_firehose_delivery_stream.s3 : key => stream.arn }
}

output "cloudwatch_log_group_name" {
  description = "CloudTrail CloudWatch log group name."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}
