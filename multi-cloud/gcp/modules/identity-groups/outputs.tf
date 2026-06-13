output "group_ids" {
  description = "Map of group key to Cloud Identity group resource id."
  value       = { for k, g in google_cloud_identity_group.this : k => g.id }
}

output "group_emails" {
  description = "Map of group key to email."
  value       = { for k, g in google_cloud_identity_group.this : k => g.group_key[0].id }
}
