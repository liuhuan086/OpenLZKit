output "log_bucket_name" {
  description = "Central log archive bucket name."
  value       = module.logging.log_bucket_name
}

output "cloudtrail_arn" {
  description = "Organization CloudTrail ARN."
  value       = module.logging.cloudtrail_arn
}
