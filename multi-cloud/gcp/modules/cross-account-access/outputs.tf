output "service_account_emails" {
  description = "Map of service account key to email."
  value       = { for k, sa in google_service_account.this : k => sa.email }
}

output "project_binding_ids" {
  description = "Map of binding key to project IAM member id."
  value       = { for k, b in google_project_iam_member.this : k => b.id }
}
