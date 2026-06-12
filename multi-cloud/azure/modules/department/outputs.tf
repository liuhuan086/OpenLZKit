output "management_group_ids" {
  description = "Map of department key to its management group resource id."
  value       = { for k, mg in azurerm_management_group.this : k => mg.id }
}

output "admin_role_assignment_ids" {
  description = "Map of department key to admin role assignment id."
  value       = { for k, a in azurerm_role_assignment.admin : k => a.id }
}
