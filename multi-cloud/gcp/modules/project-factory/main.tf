resource "google_project" "this" {
  for_each = var.projects

  name            = each.value.name
  project_id      = each.value.project_id
  folder_id       = each.value.folder_id
  billing_account = each.value.billing_account
  labels          = merge(var.common_labels, each.value.labels)

  # Never create the insecure default network; provision networking deliberately
  # (Shared VPC). Hardcoded so it cannot be overridden to true.
  auto_create_network = false
}
