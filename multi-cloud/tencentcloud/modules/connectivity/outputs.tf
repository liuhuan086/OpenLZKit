output "ccn_id" {
  description = "Created CCN id."
  value       = tencentcloud_ccn.this.id
}

output "attachment_ids" {
  description = "Map of attachment key to id."
  value       = { for k, a in tencentcloud_ccn_attachment.this : k => a.id }
}
