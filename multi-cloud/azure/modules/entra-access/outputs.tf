output "group_object_ids" {
  description = "Map of group key to Entra group object id."
  value       = { for k, g in azuread_group.this : k => g.object_id }
}

output "role_assignment_ids" {
  description = "Map of assignment key to role assignment id."
  value       = { for k, a in azurerm_role_assignment.this : k => a.id }
}
