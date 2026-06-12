output "policy_definition_ids" {
  description = "Map of policy definition key to its id."
  value       = { for k, p in azurerm_policy_definition.this : k => p.id }
}

output "policy_assignment_ids" {
  description = "Map of assignment key to its id."
  value       = { for k, a in azurerm_management_group_policy_assignment.this : k => a.id }
}
