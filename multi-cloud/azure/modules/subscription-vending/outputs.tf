output "subscription_ids" {
  description = "Map of alias to created subscription id."
  value       = { for k, s in azurerm_subscription.this : k => s.subscription_id }
}

output "associated_subscription_ids" {
  description = "Map of association key to the associated subscription id."
  value       = { for k, a in azurerm_management_group_subscription_association.this : k => a.subscription_id }
}
