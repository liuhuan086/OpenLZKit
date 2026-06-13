variable "project_id" {
  description = "Project id for the provider (security project)."
  type        = string
}

variable "org_id" {
  description = "Organization id (numeric)."
  type        = string
}

variable "findings_dataset" {
  description = "BigQuery dataset for SCC findings export (\"projects/<p>/datasets/<d>\")."
  type        = string
}

variable "findings_topic" {
  description = "Pub/Sub topic for SCC active-finding notifications (\"projects/<p>/topics/<t>\")."
  type        = string
}

provider "google" {
  project = var.project_id
}

# 45-compliance: Security Command Center findings export + notification. Runtime
# compliance complementing the plan-time Conftest gate and org-policy guardrails.
module "compliance" {
  source       = "../../modules/compliance"
  organization = var.org_id

  bigquery_exports = {
    active-findings = {
      export_id = "lz-active-findings"
      dataset   = var.findings_dataset
      filter    = "state=\"ACTIVE\""
    }
  }

  notification_configs = {
    high-severity = {
      config_id    = "lz-high-severity"
      pubsub_topic = var.findings_topic
      filter       = "state=\"ACTIVE\" AND severity=\"HIGH\""
    }
  }
}

output "bigquery_export_ids" {
  value = module.compliance.bigquery_export_ids
}
