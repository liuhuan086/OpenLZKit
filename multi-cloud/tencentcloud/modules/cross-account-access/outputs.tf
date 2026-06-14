output "role_ids" {
  description = "Map of role key to CAM role id."
  value       = { for k, r in tencentcloud_cam_role.this : k => r.id }
}
