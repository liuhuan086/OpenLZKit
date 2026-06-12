output "workspace_id" {
  description = "Log Analytics workspace id."
  value       = azurerm_log_analytics_workspace.this.id
}

output "workspace_name" {
  description = "Log Analytics workspace name."
  value       = azurerm_log_analytics_workspace.this.name
}

output "diagnostic_setting_ids" {
  description = "Map of diagnostic setting key to id."
  value       = { for k, d in azurerm_monitor_diagnostic_setting.this : k => d.id }
}
