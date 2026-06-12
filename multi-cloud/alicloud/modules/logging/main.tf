data "alicloud_account" "this" {}

# Central audit log destination (SLS).
resource "alicloud_log_project" "audit" {
  project_name = "${var.name_prefix}${var.audit_project_name}"
  description  = "Central audit log project for the Landing Zone."
  tags         = var.tags
}

resource "alicloud_log_store" "audit" {
  project_name     = alicloud_log_project.audit.project_name
  logstore_name    = var.audit_logstore_name
  retention_period = var.retention_period
  shard_count      = 2
}

# Operation audit trail delivering management events to the SLS logstore above.
resource "alicloud_actiontrail_trail" "audit" {
  trail_name            = "${var.name_prefix}audit"
  sls_project_arn       = "acs:log:${var.region}:${data.alicloud_account.this.id}:project/${alicloud_log_project.audit.project_name}"
  event_rw              = "All"
  trail_region          = "All"
  is_organization_trail = var.is_organization_trail
}
