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

output "security_lake_arns" {
  description = "Security Lake data lake ARNs by key."
  value       = module.logging.security_lake_arns
}

output "security_lake_log_source_ids" {
  description = "Security Lake AWS log source ids by key."
  value       = module.logging.security_lake_log_source_ids
}
