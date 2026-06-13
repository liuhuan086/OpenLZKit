variable "logging_project_id" {
  description = "Logging project id that owns the log-archive bucket."
  type        = string
}

variable "log_bucket_name" {
  description = "Globally-unique GCS bucket name for the central log archive."
  type        = string
}

variable "org_folder_id" {
  description = "Folder id (\"folders/<id>\") whose logs are aggregated (typically the org root folder)."
  type        = string
}

provider "google" {
  project = var.logging_project_id
}

# 50-logging: central log archive + aggregated folder sink (all children).
module "logging" {
  source          = "../../modules/logging"
  project         = var.logging_project_id
  log_bucket_name = var.log_bucket_name

  sinks = {
    org-audit = {
      parent           = var.org_folder_id
      include_children = true
      # Audit logs (admin activity + data access) across all children.
      filter = "logName:\"cloudaudit.googleapis.com\""
    }
  }
}

output "log_bucket" {
  value = module.logging.log_bucket
}
