output "node_ids" {
  description = "Map of department key to its organization node id."
  value       = { for k, n in tencentcloud_organization_org_node.this : k => n.id }
}

output "admin_role_ids" {
  description = "Map of department key to admin role id."
  value       = { for k, r in tencentcloud_cam_role.admin : k => r.id }
}
