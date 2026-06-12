output "root_folder_id" {
  description = "Resource Directory root folder id."
  value       = local.root_folder_id
}

output "folder_ids" {
  description = "Map of folder key (top-level and \"<parent>/<child>\") to created folder id."
  value       = local.folder_ids
}

output "account_ids" {
  description = "Map of account key to created member account id."
  value       = { for k, a in alicloud_resource_manager_account.this : k => a.id }
}
