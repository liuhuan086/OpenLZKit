output "security_hub_enabled" {
  description = "Whether this module enables Security Hub in the current account."
  value       = var.enable_security_hub
}

output "guardduty_detector_ids" {
  description = "GuardDuty detector ids created by this module."
  value       = [for detector in aws_guardduty_detector.this : detector.id]
}

output "config_aggregator_names" {
  description = "AWS Config organization aggregator names by key."
  value       = { for key, aggregator in aws_config_configuration_aggregator.organization : key => aggregator.name }
}

output "config_rule_names" {
  description = "AWS Config managed rule names by key."
  value       = { for key, rule in aws_config_config_rule.managed : key => rule.name }
}

output "conformance_pack_names" {
  description = "AWS Config conformance pack names by key."
  value       = { for key, pack in aws_config_conformance_pack.this : key => pack.name }
}
