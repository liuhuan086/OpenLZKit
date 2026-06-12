output "config_aggregator_names" {
  description = "AWS Config organization aggregator names by key."
  value       = module.compliance.config_aggregator_names
}

output "config_rule_names" {
  description = "AWS Config managed rule names by key."
  value       = module.compliance.config_rule_names
}

output "config_recorder_names" {
  description = "AWS Config recorder names by key."
  value       = module.compliance.config_recorder_names
}

output "config_delivery_channel_names" {
  description = "AWS Config delivery channel names by key."
  value       = module.compliance.config_delivery_channel_names
}

output "conformance_pack_names" {
  description = "AWS Config conformance pack names by key."
  value       = module.compliance.conformance_pack_names
}
