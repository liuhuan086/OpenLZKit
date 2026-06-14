output "share_unit_ids" {
  description = "Map of share unit key to its unit id."
  value       = { for k, u in tencentcloud_organization_org_share_unit.this : k => u.id }
}
