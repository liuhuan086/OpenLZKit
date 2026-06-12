output "defender_plan_ids" {
  description = "Map of resource type to Defender pricing id."
  value       = { for k, p in azurerm_security_center_subscription_pricing.this : k => p.id }
}
