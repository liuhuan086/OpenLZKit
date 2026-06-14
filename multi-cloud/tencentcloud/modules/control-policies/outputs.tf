output "policy_ids" {
  description = "Map of policy key to its id."
  value       = { for k, p in tencentcloud_organization_org_manage_policy.this : k => p.id }
}
