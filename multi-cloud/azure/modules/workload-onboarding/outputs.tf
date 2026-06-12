output "resource_group_id" {
  description = "Workload resource group id."
  value       = azurerm_resource_group.this.id
}

output "identity_principal_id" {
  description = "Workload managed identity principal id."
  value       = azurerm_user_assigned_identity.workload.principal_id
}

output "tags" {
  description = "Standard FinOps tag set applied to the workload."
  value       = local.tags
}
