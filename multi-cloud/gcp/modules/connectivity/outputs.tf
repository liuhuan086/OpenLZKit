output "host_project" {
  description = "Shared VPC host project."
  value       = google_compute_shared_vpc_host_project.host.project
}

output "attached_service_projects" {
  description = "Map of key to attached service project."
  value       = { for k, s in google_compute_shared_vpc_service_project.this : k => s.service_project }
}
