output "folder_delegation_ids" {
  description = "Map of folder delegation key to id."
  value       = { for k, b in google_folder_iam_member.this : k => b.id }
}

output "subnet_delegation_ids" {
  description = "Map of subnet delegation key to id."
  value       = { for k, b in google_compute_subnetwork_iam_member.this : k => b.id }
}
