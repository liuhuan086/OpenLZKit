output "budget_ids" {
  description = "Map of budget key to its id."
  value       = { for k, b in azurerm_consumption_budget_management_group.this : k => b.id }
}
