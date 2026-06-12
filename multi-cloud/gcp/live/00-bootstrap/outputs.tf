output "state_bucket" {
  description = "GCS bucket for remote Terraform state."
  value       = google_storage_bucket.state.name
}

output "workload_identity_provider" {
  description = "Full resource name of the WIF provider for GitHub Actions auth."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "cicd_service_account_email" {
  description = "Email of the CI/CD service account to impersonate."
  value       = google_service_account.cicd.email
}
