locals {
  name = "${var.name_prefix}${var.workload_name}-${var.env}"

  # Standard FinOps label set (mirrors the other clouds' tag set).
  labels = merge({
    owner               = var.owner
    cost_center         = var.cost_center
    env                 = var.env
    project             = var.workload_name
    managed_by          = "terraform"
    data_classification = var.data_classification
  }, var.extra_labels)
}

# Workload service account for the application (impersonated, no keys).
resource "google_service_account" "workload" {
  account_id   = local.name
  project      = var.project
  display_name = "${var.workload_name} ${var.env} workload"
}

# Workload team access, scoped to the workload project only.
resource "google_project_iam_member" "team" {
  count = var.team_member == null ? 0 : 1

  project = var.project
  role    = var.team_role
  member  = var.team_member
}
