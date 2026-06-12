output "management_group_ids" {
  description = "Map of management group key (top-level and \"<parent>/<child>\") to its resource id."
  value       = local.management_group_ids
}

output "management_group_names" {
  description = "Map of management group key to its name (immutable id)."
  value = merge(
    { for k, mg in azurerm_management_group.top : k => mg.name },
    { for k, mg in azurerm_management_group.child : k => mg.name },
  )
}
