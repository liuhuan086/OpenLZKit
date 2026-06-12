output "policy_ids" {
  description = "Map of policy key to Resource Directory control policy id."
  value       = { for k, policy in alicloud_resource_manager_control_policy.this : k => policy.id }
}

output "attachment_ids" {
  description = "Map of attachment key to control policy attachment id."
  value       = { for k, attachment in alicloud_resource_manager_control_policy_attachment.this : k => attachment.id }
}
