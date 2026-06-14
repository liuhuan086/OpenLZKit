output "group_ids" {
  description = "Map of group key to CAM group id."
  value       = { for k, g in tencentcloud_cam_group.this : k => g.id }
}
