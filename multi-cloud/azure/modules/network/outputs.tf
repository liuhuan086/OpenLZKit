output "vnet_id" {
  description = "Created virtual network id."
  value       = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  description = "Map of subnet name to subnet id."
  value       = { for k, s in azurerm_subnet.this : k => s.id }
}

output "baseline_nsg_id" {
  description = "Default-deny baseline network security group id."
  value       = azurerm_network_security_group.baseline.id
}
