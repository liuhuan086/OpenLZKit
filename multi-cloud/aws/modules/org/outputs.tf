output "root_id" {
  description = "AWS Organizations root id."
  value       = local.root_id
}

output "ou_ids" {
  description = "Map of OU key (top-level and \"<parent>/<child>\") to OU id."
  value       = local.ou_ids
}
