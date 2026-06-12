output "folder_ids" {
  description = "Map of department key to Resource Directory folder id."
  value       = { for k, folder in alicloud_resource_manager_folder.department : k => folder.folder_id }
}

output "role_names" {
  description = "Map of department key to department admin RAM role name."
  value       = { for k, role in alicloud_ram_role.department_admin : k => role.role_name }
}

output "role_arns" {
  description = "Map of department key to department admin RAM role ARN."
  value       = { for k, role in alicloud_ram_role.department_admin : k => role.arn }
}

output "tag_policy_ids" {
  description = "Map of department key to department tag policy id."
  value       = { for k, policy in alicloud_tag_policy.department : k => policy.id }
}

output "standard_tags" {
  description = "Map of department key to standard FinOps tags for account/workload vending."
  value       = local.department_tags
}
