output "custom_role_ids" {
  description = "Map of role_id to the full custom role resource id."
  value       = { for k, r in google_organization_iam_custom_role.this : k => r.id }
}
