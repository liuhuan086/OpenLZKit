output "lighthouse_definition_ids" {
  description = "Map of delegation key to Lighthouse definition id."
  value       = { for k, d in azurerm_lighthouse_definition.this : k => d.id }
}

output "lighthouse_assignment_ids" {
  description = "Map of delegation key to Lighthouse assignment id."
  value       = { for k, a in azurerm_lighthouse_assignment.this : k => a.id }
}
