module "compliance" {
  source = "../../modules/compliance"

  enable_security_hub           = true
  security_hub_admin_account_id = "111122223333"
  enable_guardduty_detector     = true
  guardduty_admin_account_id    = "111122223333"

  security_hub_standards = {
    aws_foundational = {
      standards_arn = "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0"
    }
  }

  config_aggregators = {
    organization = {
      name     = "organization-compliance"
      role_arn = "arn:aws:iam::111122223333:role/config-aggregator"
    }
  }

  config_recorders = {
    default = {
      role_arn                      = "arn:aws:iam::111122223333:role/config-recorder"
      s3_bucket_name                = "example-openlzkit-config"
      s3_key_prefix                 = "config"
      include_global_resource_types = true
      snapshot_delivery_frequency   = "TwentyFour_Hours"
      enabled                       = true
    }
  }

  config_managed_rules = {
    required_tags = {
      name              = "required-tags"
      source_identifier = "REQUIRED_TAGS"
      input_parameters = {
        tag1Key = "owner"
        tag2Key = "cost_center"
        tag3Key = "env"
        tag4Key = "project"
      }
    }
    s3_bucket_public_read_prohibited = {
      name              = "s3-bucket-public-read-prohibited"
      source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
    }
    encrypted_volumes = {
      name              = "encrypted-volumes"
      source_identifier = "ENCRYPTED_VOLUMES"
    }
  }

  conformance_packs = {
    storage_security = {
      name = "storage-security"
      template_body = yamlencode({
        Resources = {
          S3BucketPublicReadProhibited = {
            Type = "AWS::Config::ConfigRule"
            Properties = {
              ConfigRuleName = "s3-bucket-public-read-prohibited"
              Source = {
                Owner            = "AWS"
                SourceIdentifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
              }
            }
          }
        }
      })
    }
  }
}
