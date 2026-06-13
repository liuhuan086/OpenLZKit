output "bigquery_export_ids" {
  description = "Map of export key to resource id."
  value       = { for k, e in google_scc_organization_scc_big_query_export.this : k => e.id }
}

output "notification_config_ids" {
  description = "Map of notification key to resource id."
  value       = { for k, n in google_scc_notification_config.this : k => n.id }
}
