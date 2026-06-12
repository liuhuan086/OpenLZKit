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
