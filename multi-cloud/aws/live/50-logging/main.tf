module "logging" {
  source = "../../modules/logging"

  create_log_bucket = var.create_log_bucket
  log_bucket_name   = var.log_bucket_name
  create_kms_key    = var.create_kms_key
  kms_key_arn       = var.kms_key_arn
  cloudtrail        = var.cloudtrail
  event_selectors   = var.event_selectors
  firehose_streams  = var.firehose_streams

  security_lake_data_lakes      = var.security_lake_data_lakes
  security_lake_aws_log_sources = var.security_lake_aws_log_sources
}
