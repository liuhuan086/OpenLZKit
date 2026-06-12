output "role_names" {
  description = "Map of role key to cross-account RAM role name."
  value       = { for k, role in alicloud_ram_role.cross_account : k => role.role_name }
}

output "role_arns" {
  description = "Map of role key to cross-account RAM role ARN."
  value       = { for k, role in alicloud_ram_role.cross_account : k => role.arn }
}

output "resource_share_ids" {
  description = "Map of share key to Resource Share id."
  value       = { for k, share in alicloud_resource_manager_resource_share.this : k => share.id }
}
