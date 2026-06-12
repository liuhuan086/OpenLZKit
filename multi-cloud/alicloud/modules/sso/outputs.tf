output "directory_id" {
  description = "CloudSSO directory id."
  value       = local.directory_id
}

output "group_ids" {
  description = "Map of group key to CloudSSO group id."
  value       = { for k, group in alicloud_cloud_sso_group.this : k => group.group_id }
}

output "user_ids" {
  description = "Map of user key to CloudSSO user id."
  value       = { for k, user in alicloud_cloud_sso_user.this : k => user.user_id }
}

output "access_configuration_ids" {
  description = "Map of access configuration key to CloudSSO access configuration id."
  value       = { for k, ac in alicloud_cloud_sso_access_configuration.this : k => ac.access_configuration_id }
}

output "assignment_ids" {
  description = "Map of assignment key to CloudSSO access assignment id."
  value       = { for k, assignment in alicloud_cloud_sso_access_assignment.this : k => assignment.id }
}
