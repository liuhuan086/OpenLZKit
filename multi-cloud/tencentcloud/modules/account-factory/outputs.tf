output "member_ids" {
  description = "Map of member key to created member id (UIN)."
  value       = { for k, m in tencentcloud_organization_org_member.this : k => m.id }
}
