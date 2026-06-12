module "logging" {
  source = "../../modules/logging"

  log_bucket_name               = "openlzkit-example-log-archive"
  object_lock_retention_days    = 365
  cloudwatch_log_group_name     = "/aws/openlzkit/example/cloudtrail"
  cloudwatch_log_retention_days = 365

  cloudtrail = {
    name                          = "organization"
    s3_key_prefix                 = "cloudtrail"
    include_global_service_events = true
    is_multi_region_trail         = true
    is_organization_trail         = true
    enable_log_file_validation    = true
  }

  event_selectors = [{
    read_write_type           = "All"
    include_management_events = true
    data_resources = [{
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::example-sensitive-bucket/"]
    }]
  }]

  firehose_streams = {
    application_json = {
      name     = "application-json-archive"
      role_arn = "arn:aws:iam::111122223333:role/firehose-log-archive"
      prefix   = "application/!{timestamp:yyyy/MM/dd}/"
      tags = {
        owner       = "platform-logging"
        cost_center = "cc-7000"
        env         = "shared"
        project     = "log-archive"
      }
    }
  }
}
