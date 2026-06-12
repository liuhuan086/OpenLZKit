resource "google_project" "this" {
  for_each = var.projects

  name                = each.value.name
  project_id          = each.value.project_id
  folder_id           = each.value.folder_id
  billing_account     = each.value.billing_account
  auto_create_network = each.value.auto_create_network
  labels              = merge(var.common_labels, each.value.labels)
}
