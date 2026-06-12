output "log_bucket_name" {
  description = "Central log archive bucket name."
  value       = module.logging.log_bucket_name
}

output "cloudtrail_arn" {
  description = "Organization CloudTrail ARN."
  value       = module.logging.cloudtrail_arn
}

output "firehose_stream_arns" {
  description = "Firehose delivery stream ARNs by key."
  value       = module.logging.firehose_stream_arns
}
