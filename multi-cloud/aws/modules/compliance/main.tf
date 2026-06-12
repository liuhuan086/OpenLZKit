locals {
  config_aggregator_tags = {
    for key, aggregator in var.config_aggregators :
    key => merge(var.common_tags, aggregator.tags)
  }

  config_rule_tags = {
    for key, rule in var.config_managed_rules :
    key => merge(var.common_tags, rule.tags)
  }
}

resource "aws_securityhub_account" "this" {
  count = var.enable_security_hub ? 1 : 0
}

resource "aws_securityhub_organization_admin_account" "this" {
  count = var.security_hub_admin_account_id == null ? 0 : 1

  admin_account_id = var.security_hub_admin_account_id
}

resource "aws_securityhub_standards_subscription" "this" {
  for_each = var.security_hub_standards

  standards_arn = each.value.standards_arn

  depends_on = [aws_securityhub_account.this]
}

resource "aws_guardduty_detector" "this" {
  count = var.enable_guardduty_detector ? 1 : 0

  enable = true
  tags   = var.common_tags
}

resource "aws_guardduty_organization_admin_account" "this" {
  count = var.guardduty_admin_account_id == null ? 0 : 1

  admin_account_id = var.guardduty_admin_account_id
}

resource "aws_config_configuration_aggregator" "organization" {
  for_each = var.config_aggregators

  name = each.value.name
  tags = local.config_aggregator_tags[each.key]

  organization_aggregation_source {
    all_regions = each.value.all_regions
    regions     = each.value.all_regions ? null : each.value.regions
    role_arn    = each.value.role_arn
  }
}

resource "aws_config_configuration_recorder" "this" {
  for_each = var.config_recorders

  name     = each.value.name
  role_arn = each.value.role_arn

  recording_group {
    all_supported                 = each.value.all_supported
    include_global_resource_types = each.value.include_global_resource_types
    resource_types                = length(each.value.resource_types) == 0 ? null : each.value.resource_types
  }

  recording_mode {
    recording_frequency = each.value.recording_frequency
  }
}

resource "aws_config_delivery_channel" "this" {
  for_each = var.config_recorders

  name           = each.value.delivery_channel_name == null ? "${each.value.name}-delivery" : each.value.delivery_channel_name
  s3_bucket_name = each.value.s3_bucket_name
  s3_key_prefix  = each.value.s3_key_prefix
  s3_kms_key_arn = each.value.s3_kms_key_arn
  sns_topic_arn  = each.value.sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = each.value.snapshot_delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  for_each = {
    for key, recorder in var.config_recorders : key => recorder
    if recorder.enabled
  }

  name       = aws_config_configuration_recorder.this[each.key].name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_config_rule" "managed" {
  for_each = var.config_managed_rules

  name                        = each.value.name
  description                 = each.value.description
  input_parameters            = length(each.value.input_parameters) == 0 ? null : jsonencode(each.value.input_parameters)
  maximum_execution_frequency = each.value.maximum_execution_frequency
  tags                        = local.config_rule_tags[each.key]

  source {
    owner             = "AWS"
    source_identifier = each.value.source_identifier
  }
}

resource "aws_config_conformance_pack" "this" {
  for_each = var.conformance_packs

  name                   = each.value.name
  template_body          = each.value.template_body
  delivery_s3_bucket     = each.value.delivery_s3_bucket
  delivery_s3_key_prefix = each.value.delivery_s3_key_prefix
}
