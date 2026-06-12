output "custom_role_ids" {
  description = "Map of custom role key to its role definition resource id."
  value       = { for k, r in azurerm_role_definition.this : k => r.role_definition_resource_id }
}

output "role_assignment_ids" {
  description = "Map of assignment key to role assignment id."
  value       = { for k, a in azurerm_role_assignment.this : k => a.id }
}
