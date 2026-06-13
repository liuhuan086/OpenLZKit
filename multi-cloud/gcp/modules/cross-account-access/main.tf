resource "google_service_account" "this" {
  for_each = var.service_accounts

  account_id   = each.value.account_id
  project      = each.value.project
  display_name = each.value.display_name
  description  = each.value.description
}

resource "google_project_iam_member" "this" {
  for_each = var.project_bindings

  project = each.value.project
  role    = each.value.role
  member  = each.value.service_account_key == null ? each.value.member : "serviceAccount:${google_service_account.this[each.value.service_account_key].email}"
}

# Allow a repo-scoped federated principalSet to impersonate the service account
# (no service-account key is created or downloaded).
resource "google_service_account_iam_member" "wif" {
  for_each = var.wif_bindings

  service_account_id = google_service_account.this[each.value.service_account_key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = each.value.member
}
