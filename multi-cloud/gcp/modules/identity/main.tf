resource "google_organization_iam_custom_role" "this" {
  for_each = var.custom_org_roles

  org_id      = var.org_id
  role_id     = each.key
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  stage       = each.value.stage
}

resource "google_folder_iam_member" "this" {
  for_each = var.folder_bindings

  folder = each.value.folder
  role   = each.value.role
  member = each.value.member
}

resource "google_project_iam_member" "this" {
  for_each = var.project_bindings

  project = each.value.project
  role    = each.value.role
  member  = each.value.member
}
