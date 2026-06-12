locals {
  kms_key_arn = var.create_kms_key ? aws_kms_key.logs[0].arn : var.kms_key_arn
  bucket_id   = var.create_log_bucket ? aws_s3_bucket.log_archive[0].id : var.log_bucket_name
  bucket_arn  = var.create_log_bucket ? aws_s3_bucket.log_archive[0].arn : "arn:aws:s3:::${var.log_bucket_name}"

  firehose_bucket_arns = {
    for key, stream in var.firehose_streams :
    key => stream.bucket_arn == null ? local.bucket_arn : stream.bucket_arn
  }

  firehose_kms_key_arns = {
    for key, stream in var.firehose_streams :
    key => stream.kms_key_arn == null ? local.kms_key_arn : stream.kms_key_arn
  }

  firehose_tags = {
    for key, stream in var.firehose_streams :
    key => merge(var.common_tags, stream.tags)
  }
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "logs" {
  count = var.create_kms_key ? 1 : 0

  description             = "OpenLZKit log archive encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.common_tags
}

resource "aws_kms_alias" "logs" {
  count = var.create_kms_key ? 1 : 0

  name          = var.kms_alias_name
  target_key_id = aws_kms_key.logs[0].key_id
}

resource "aws_s3_bucket" "log_archive" {
  count = var.create_log_bucket ? 1 : 0

  bucket              = var.log_bucket_name
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags                = merge(var.common_tags, { Name = var.log_bucket_name })
}

resource "aws_s3_bucket_public_access_block" "log_archive" {
  count = var.create_log_bucket ? 1 : 0

  bucket                  = aws_s3_bucket.log_archive[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "log_archive" {
  count = var.create_log_bucket ? 1 : 0

  bucket = aws_s3_bucket.log_archive[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_archive" {
  count = var.create_log_bucket ? 1 : 0

  bucket = aws_s3_bucket.log_archive[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.kms_key_arn
      sse_algorithm     = local.kms_key_arn == null ? "AES256" : "aws:kms"
    }
  }
}

resource "aws_s3_bucket_object_lock_configuration" "log_archive" {
  count = var.create_log_bucket && var.object_lock_enabled ? 1 : 0

  bucket = aws_s3_bucket.log_archive[0].id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = var.object_lock_retention_days
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_bucket" {
  statement {
    sid = "AWSCloudTrailAclCheck"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [local.bucket_arn]
  }

  statement {
    sid = "AWSCloudTrailWrite"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:PutObject"]
    resources = [
      "${local.bucket_arn}/${var.cloudtrail.s3_key_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "${local.bucket_arn}/${var.cloudtrail.s3_key_prefix}/AWSLogs/o-*/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count = var.create_log_bucket ? 1 : 0

  bucket = aws_s3_bucket.log_archive[0].id
  policy = data.aws_iam_policy_document.cloudtrail_bucket.json
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = var.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_log_retention_days
  kms_key_id        = local.kms_key_arn
  tags              = var.common_tags
}

resource "aws_cloudtrail" "organization" {
  name                          = var.cloudtrail.name
  s3_bucket_name                = local.bucket_id
  s3_key_prefix                 = var.cloudtrail.s3_key_prefix
  include_global_service_events = var.cloudtrail.include_global_service_events
  is_multi_region_trail         = var.cloudtrail.is_multi_region_trail
  is_organization_trail         = var.cloudtrail.is_organization_trail
  enable_log_file_validation    = var.cloudtrail.enable_log_file_validation
  enable_logging                = var.cloudtrail.enable_logging
  kms_key_id                    = local.kms_key_arn
  cloud_watch_logs_group_arn    = var.cloudtrail.cloud_watch_logs_role_arn == null ? null : "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = var.cloudtrail.cloud_watch_logs_role_arn
  tags                          = merge(var.common_tags, var.cloudtrail.tags)

  dynamic "event_selector" {
    for_each = var.event_selectors
    content {
      read_write_type           = event_selector.value.read_write_type
      include_management_events = event_selector.value.include_management_events

      dynamic "data_resource" {
        for_each = event_selector.value.data_resources
        content {
          type   = data_resource.value.type
          values = data_resource.value.values
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

resource "aws_kinesis_firehose_delivery_stream" "s3" {
  for_each = var.firehose_streams

  name        = each.value.name
  destination = "extended_s3"
  tags        = local.firehose_tags[each.key]

  extended_s3_configuration {
    role_arn            = each.value.role_arn
    bucket_arn          = local.firehose_bucket_arns[each.key]
    prefix              = each.value.prefix
    error_output_prefix = each.value.error_output_prefix
    buffering_interval  = each.value.buffering_interval
    buffering_size      = each.value.buffering_size
    compression_format  = each.value.compression_format
    kms_key_arn         = local.firehose_kms_key_arns[each.key]

    dynamic "cloudwatch_logging_options" {
      for_each = each.value.cloudwatch_log_group_name == null ? [] : [each.value]
      content {
        enabled         = true
        log_group_name  = cloudwatch_logging_options.value.cloudwatch_log_group_name
        log_stream_name = cloudwatch_logging_options.value.cloudwatch_log_stream_name
      }
    }
  }
}
