output "account_ids" {
  description = "Map of account key to created member account id."
  value       = { for k, account in alicloud_resource_manager_account.this : k => account.id }
}

output "account_display_names" {
  description = "Map of account key to created member account display name."
  value       = { for k, account in alicloud_resource_manager_account.this : k => account.display_name }
}
