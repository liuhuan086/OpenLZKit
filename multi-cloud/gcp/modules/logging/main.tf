resource "google_storage_bucket" "log_archive" {
  name     = var.log_bucket_name
  project  = var.project
  location = var.location

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning {
    enabled = true
  }

  retention_policy {
    retention_period = var.retention_days * 86400
    is_locked        = var.lock_retention
  }
}

# Aggregated folder log sinks routing matching logs to the central archive.
resource "google_logging_folder_sink" "this" {
  for_each = var.sinks

  name             = "${var.name_prefix}${each.key}"
  folder           = each.value.parent
  destination      = "storage.googleapis.com/${google_storage_bucket.log_archive.name}"
  filter           = each.value.filter
  include_children = each.value.include_children
}

# Grant each sink's writer identity permission to write to the archive bucket.
resource "google_storage_bucket_iam_member" "sink_writer" {
  for_each = var.sinks

  bucket = google_storage_bucket.log_archive.name
  role   = "roles/storage.objectCreator"
  member = google_logging_folder_sink.this[each.key].writer_identity
}
