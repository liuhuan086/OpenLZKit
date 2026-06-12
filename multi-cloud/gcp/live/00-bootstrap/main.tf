provider "google" {
  project = var.project_id
  region  = var.region
}

# --- Remote state bucket ---------------------------------------------------
resource "google_storage_bucket" "state" {
  name     = var.state_bucket_name
  project  = var.project_id
  location = var.location

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false
  labels                      = var.labels

  versioning {
    enabled = true
  }
}

# --- GitHub Actions Workload Identity Federation ---------------------------
resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = "GitHub Actions"
  description               = "OIDC federation for GitHub Actions CI/CD."
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "GitHub"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }

  # Restrict the provider to this repository only.
  attribute_condition = "assertion.repository == \"${var.github_owner}/${var.github_repo}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# --- CI service account (plan-only; no key is created) ---------------------
resource "google_service_account" "cicd" {
  project      = var.project_id
  account_id   = "${var.name_prefix}cicd-plan"
  display_name = "CI/CD plan (GitHub OIDC)"
}

# Allow only this repo's federated identity to impersonate the CI service account.
resource "google_service_account_iam_member" "wif" {
  service_account_id = google_service_account.cicd.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_owner}/${var.github_repo}"
}
