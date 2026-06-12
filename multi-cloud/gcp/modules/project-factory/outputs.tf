output "project_ids" {
  description = "Map of project key to created project id."
  value       = { for k, p in google_project.this : k => p.project_id }
}

output "project_numbers" {
  description = "Map of project key to project number."
  value       = { for k, p in google_project.this : k => p.number }
}
