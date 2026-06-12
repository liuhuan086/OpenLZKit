output "delegated_administrator_ids" {
  description = "Map of delegated administrator key to resource id."
  value       = { for k, delegation in alicloud_resource_manager_delegated_administrator.this : k => delegation.id }
}

output "cloud_sso_delegate_account_id" {
  description = "CloudSSO delegated account resource id."
  value       = try(alicloud_cloud_sso_delegate_account.this[0].id, null)
}

output "resource_share_ids" {
  description = "Map of resource share key to resource share id."
  value       = { for k, share in alicloud_resource_manager_resource_share.this : k => share.id }
}
