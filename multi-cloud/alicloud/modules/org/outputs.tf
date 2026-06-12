output "root_folder_id" {
  description = "Resource Directory root folder id."
  value       = local.root_folder_id
}

output "folder_ids" {
  description = "Map of folder key (top-level and \"<parent>/<child>\") to created folder id."
  value       = local.folder_ids
}
