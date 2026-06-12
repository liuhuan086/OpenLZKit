output "folder_names" {
  description = "Map of folder key (top-level and \"<parent>/<child>\") to its resource name (\"folders/<number>\")."
  value       = local.folder_names
}

output "folder_ids" {
  description = "Map of folder key to its numeric folder id."
  value = merge(
    { for k, f in google_folder.top : k => f.folder_id },
    { for k, f in google_folder.child : k => f.folder_id },
  )
}
