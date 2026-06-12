output "aggregator_id" {
  description = "Cloud Config aggregator id."
  value       = alicloud_config_aggregator.this.id
}

output "aggregate_rule_ids" {
  description = "Aggregate config rule ids by key."
  value       = { for k, rule in alicloud_config_aggregate_config_rule.this : k => rule.config_rule_id }
}

output "compliance_pack_ids" {
  description = "Aggregate compliance pack ids by key."
  value       = { for k, pack in alicloud_config_aggregate_compliance_pack.this : k => pack.aggregator_compliance_pack_id }
}

output "delivery_channel_ids" {
  description = "Aggregate delivery channel ids by key."
  value       = { for k, delivery in alicloud_config_aggregate_delivery.this : k => delivery.delivery_channel_id }
}
