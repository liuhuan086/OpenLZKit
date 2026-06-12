locals {
  compliance_pack_rule_ids = {
    for pack_key, pack in var.compliance_packs :
    pack_key => [
      for rule_key in pack.rule_keys :
      alicloud_config_aggregate_config_rule.this[rule_key].config_rule_id
    ]
  }
}

resource "alicloud_config_configuration_recorder" "this" {
  count = var.enable_configuration_recorder ? 1 : 0

  enterprise_edition = var.enterprise_edition
  resource_types     = var.recorder_resource_types
}

resource "alicloud_config_aggregator" "this" {
  aggregator_name = var.aggregator_name
  description     = var.aggregator_description
  aggregator_type = var.aggregator_type
  folder_id       = var.folder_id

  dynamic "aggregator_accounts" {
    for_each = var.aggregator_accounts
    content {
      account_id   = aggregator_accounts.value.account_id
      account_name = aggregator_accounts.value.account_name
      account_type = aggregator_accounts.value.account_type
    }
  }
}

resource "alicloud_config_aggregate_config_rule" "this" {
  for_each = var.aggregate_rules

  aggregator_id               = alicloud_config_aggregator.this.id
  aggregate_config_rule_name  = each.value.name
  description                 = each.value.description
  source_owner                = each.value.source_owner
  source_identifier           = each.value.source_identifier
  config_rule_trigger_types   = each.value.trigger_types
  resource_types_scope        = each.value.resource_types_scope
  risk_level                  = each.value.risk_level
  input_parameters            = each.value.input_parameters
  maximum_execution_frequency = each.value.maximum_execution_frequency
  region_ids_scope            = each.value.region_ids_scope
  resource_group_ids_scope    = each.value.resource_group_ids_scope
  tag_key_scope               = each.value.tag_key_scope
  tag_value_scope             = each.value.tag_value_scope
  exclude_resource_ids_scope  = each.value.exclude_resource_ids_scope
  status                      = each.value.status
}

resource "alicloud_config_aggregate_compliance_pack" "this" {
  for_each = var.compliance_packs

  aggregator_id                = alicloud_config_aggregator.this.id
  aggregate_compliance_pack_name = each.value.name
  description                  = each.value.description
  risk_level                   = each.value.risk_level
  compliance_pack_template_id  = each.value.compliance_pack_template_id

  dynamic "config_rule_ids" {
    for_each = local.compliance_pack_rule_ids[each.key]
    content {
      config_rule_id = config_rule_ids.value
    }
  }

  lifecycle {
    precondition {
      condition     = alltrue([for rule_key in each.value.rule_keys : contains(keys(var.aggregate_rules), rule_key)])
      error_message = "Each compliance pack rule_key must exist in var.aggregate_rules."
    }
  }
}

resource "alicloud_config_aggregate_delivery" "this" {
  for_each = var.deliveries

  aggregator_id                           = alicloud_config_aggregator.this.id
  delivery_channel_name                   = each.value.name
  description                             = each.value.description
  delivery_channel_type                   = each.value.delivery_channel_type
  delivery_channel_target_arn             = each.value.delivery_channel_target_arn
  oversized_data_oss_target_arn           = each.value.oversized_data_oss_target_arn
  delivery_channel_condition              = each.value.delivery_channel_condition
  configuration_item_change_notification  = each.value.configuration_item_change_notification
  configuration_snapshot                  = each.value.configuration_snapshot
  non_compliant_notification              = each.value.non_compliant_notification
  status                                  = each.value.status
}
