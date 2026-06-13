resource "google_cloud_identity_group" "this" {
  for_each = var.groups

  parent       = var.customer_id
  display_name = each.value.display_name
  description  = each.value.description

  group_key {
    id = each.value.email
  }

  labels = {
    "cloudidentity.googleapis.com/groups.discussion_forum" = ""
  }
}

resource "google_folder_iam_member" "this" {
  for_each = var.folder_bindings

  folder = each.value.folder
  role   = each.value.role
  member = "group:${google_cloud_identity_group.this[each.value.group_key].group_key[0].id}"
}

resource "google_project_iam_member" "this" {
  for_each = var.project_bindings

  project = each.value.project
  role    = each.value.role
  member  = "group:${google_cloud_identity_group.this[each.value.group_key].group_key[0].id}"
}
