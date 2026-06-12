output "managed_identity_principal_ids" {
  description = "Map of managed identity key to its principal (object) id."
  value       = { for k, mi in azurerm_user_assigned_identity.this : k => mi.principal_id }
}

output "managed_identity_client_ids" {
  description = "Map of managed identity key to its client id."
  value       = { for k, mi in azurerm_user_assigned_identity.this : k => mi.client_id }
}

output "role_assignment_ids" {
  description = "Map of assignment key to role assignment id."
  value       = { for k, a in azurerm_role_assignment.this : k => a.id }
}
