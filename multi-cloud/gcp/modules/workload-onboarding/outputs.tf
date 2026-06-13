output "service_account_email" {
  description = "Workload service account email."
  value       = google_service_account.workload.email
}

output "labels" {
  description = "Standard FinOps label set for the workload (apply to the project/resources)."
  value       = local.labels
}
