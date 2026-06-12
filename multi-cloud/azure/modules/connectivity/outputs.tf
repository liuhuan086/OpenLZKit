output "peering_ids" {
  description = "Map of peering key to id."
  value       = { for k, p in azurerm_virtual_network_peering.this : k => p.id }
}
