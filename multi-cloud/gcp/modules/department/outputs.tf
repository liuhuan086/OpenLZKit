output "folder_names" {
  description = "Map of department key to its folder resource name."
  value       = { for k, f in google_folder.this : k => f.name }
}

output "folder_ids" {
  description = "Map of department key to numeric folder id."
  value       = { for k, f in google_folder.this : k => f.folder_id }
}
