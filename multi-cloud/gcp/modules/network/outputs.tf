output "network_id" {
  description = "Created VPC network id."
  value       = google_compute_network.this.id
}

output "network_self_link" {
  description = "VPC network self link."
  value       = google_compute_network.this.self_link
}

output "subnet_ids" {
  description = "Map of subnet name to subnet id."
  value       = { for k, s in google_compute_subnetwork.this : k => s.id }
}
