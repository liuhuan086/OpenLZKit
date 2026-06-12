output "boolean_policy_ids" {
  description = "Map of boolean policy key to its resource id."
  value       = { for k, p in google_org_policy_policy.boolean : k => p.id }
}

output "list_policy_ids" {
  description = "Map of list policy key to its resource id."
  value       = { for k, p in google_org_policy_policy.list : k => p.id }
}
