output "log_bucket" {
  description = "Central log-archive bucket name."
  value       = google_storage_bucket.log_archive.name
}

output "sink_writer_identities" {
  description = "Map of sink key to its writer identity."
  value       = { for k, s in google_logging_folder_sink.this : k => s.writer_identity }
}
