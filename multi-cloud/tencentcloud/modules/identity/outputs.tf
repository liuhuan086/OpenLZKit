output "policy_ids" {
  description = "Map of custom policy key to id."
  value       = { for k, p in tencentcloud_cam_policy.this : k => p.id }
}

output "role_ids" {
  description = "Map of role key to id."
  value       = { for k, r in tencentcloud_cam_role.this : k => r.id }
}
