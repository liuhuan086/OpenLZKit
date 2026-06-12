output "role_names" {
  description = "Map of role key to created RAM role name."
  value       = { for k, r in alicloud_ram_role.this : k => r.role_name }
}

output "role_arns" {
  description = "Map of role key to RAM role ARN."
  value       = { for k, r in alicloud_ram_role.this : k => r.arn }
}
