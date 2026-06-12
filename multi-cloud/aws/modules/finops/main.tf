locals {
  cur_bucket_tags = {
    for key, bucket in var.cur_buckets :
    key => merge(var.common_tags, bucket.tags)
  }

  anomaly_subscription_monitor_arns = {
    for key, subscription in var.anomaly_subscriptions :
    key => [for monitor_key in subscription.monitor_keys : aws_ce_anomaly_monitor.this[monitor_key].arn]
  }

  anomaly_subscription_emails = merge(concat([{}], [
    for subscription_key, subscription in var.anomaly_subscriptions : {
      for email in subscription.subscriber_emails :
      "${subscription_key}:email:${email}" => {
        subscription = subscription_key
        type         = "EMAIL"
        address      = email
      }
    }
  ])...)

  anomaly_subscription_sns = merge(concat([{}], [
    for subscription_key, subscription in var.anomaly_subscriptions : {
      for topic_arn in subscription.subscriber_sns :
      "${subscription_key}:sns:${topic_arn}" => {
        subscription = subscription_key
        type         = "SNS"
        address      = topic_arn
      }
    }
  ])...)

  anomaly_subscription_subscribers = merge(local.anomaly_subscription_emails, local.anomaly_subscription_sns)

  cur_report_bucket_names = {
    for key, report in var.cur_reports :
    key => report.s3_bucket_name != null ? report.s3_bucket_name : aws_s3_bucket.cur[report.s3_bucket_key].bucket
  }
}

data "aws_caller_identity" "current" {}

resource "aws_budgets_budget" "this" {
  for_each = var.budgets

  name         = each.value.name
  budget_type  = each.value.budget_type
  limit_amount = each.value.limit_amount
  limit_unit   = each.value.limit_unit
  time_unit    = each.value.time_unit

  dynamic "cost_filter" {
    for_each = each.value.cost_filters
    content {
      name   = cost_filter.key
      values = cost_filter.value
    }
  }

  dynamic "notification" {
    for_each = each.value.notifications
    content {
      comparison_operator        = notification.value.comparison_operator
      threshold                  = notification.value.threshold
      threshold_type             = notification.value.threshold_type
      notification_type          = notification.value.notification_type
      subscriber_email_addresses = notification.value.subscriber_email_addresses
      subscriber_sns_topic_arns  = notification.value.subscriber_sns_topic_arns
    }
  }
}

resource "aws_ce_anomaly_monitor" "this" {
  for_each = var.anomaly_monitors

  name                  = each.value.name
  monitor_type          = each.value.monitor_type
  monitor_dimension     = each.value.monitor_dimension
  monitor_specification = each.value.monitor_specification
}

resource "aws_ce_anomaly_subscription" "this" {
  for_each = var.anomaly_subscriptions

  name             = each.value.name
  frequency        = each.value.frequency
  monitor_arn_list = local.anomaly_subscription_monitor_arns[each.key]

  dynamic "subscriber" {
    for_each = {
      for key, subscriber in local.anomaly_subscription_subscribers :
      key => subscriber
      if subscriber.subscription == each.key
    }
    content {
      type    = subscriber.value.type
      address = subscriber.value.address
    }
  }
}

resource "aws_ce_cost_category" "this" {
  for_each = var.cost_categories

  name         = each.value.name
  rule_version = each.value.rule_version

  dynamic "rule" {
    for_each = each.value.rules
    content {
      value = rule.value.value

      rule {
        dimension {
          key           = rule.value.dimension.key
          values        = rule.value.dimension.values
          match_options = rule.value.dimension.match_options
        }
      }
    }
  }
}

resource "aws_s3_bucket" "cur" {
  for_each = var.cur_buckets

  bucket        = each.value.name
  force_destroy = each.value.force_destroy
  tags          = local.cur_bucket_tags[each.key]
}

resource "aws_s3_bucket_public_access_block" "cur" {
  for_each = var.cur_buckets

  bucket                  = aws_s3_bucket.cur[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "cur" {
  for_each = var.cur_buckets

  bucket = aws_s3_bucket.cur[each.key].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "cur" {
  for_each = var.cur_buckets

  bucket = aws_s3_bucket.cur[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cur" {
  for_each = var.cur_buckets

  bucket = aws_s3_bucket.cur[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "cur" {
  for_each = var.cur_buckets

  bucket = aws_s3_bucket.cur[each.key].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowBillingReportsBucketRead"
        Effect = "Allow"
        Principal = {
          Service = "billingreports.amazonaws.com"
        }
        Action = [
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy",
        ]
        Resource = aws_s3_bucket.cur[each.key].arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AllowBillingReportsWrite"
        Effect = "Allow"
        Principal = {
          Service = "billingreports.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cur[each.key].arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
    ]
  })
}

resource "aws_cur_report_definition" "this" {
  for_each = var.cur_reports

  report_name                = each.value.report_name
  time_unit                  = each.value.time_unit
  format                     = each.value.format
  compression                = each.value.compression
  additional_schema_elements = each.value.additional_schema_elements
  additional_artifacts       = each.value.additional_artifacts
  s3_bucket                  = local.cur_report_bucket_names[each.key]
  s3_prefix                  = each.value.s3_prefix
  s3_region                  = each.value.s3_region
  refresh_closed_reports     = each.value.refresh_closed_reports
  report_versioning          = each.value.report_versioning
}
