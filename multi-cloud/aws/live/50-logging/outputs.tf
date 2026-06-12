output "log_bucket_name" {
  description = "Central log archive bucket name."
  value       = module.logging.log_bucket_name
}

output "kms_key_arn" {
  description = "KMS key ARN used for log encryption."
  value       = module.logging.kms_key_arn
}

output "cloudtrail_arn" {
  description = "Organization CloudTrail ARN."
  value       = module.logging.cloudtrail_arn
}
