locals {
  owner_delegations = [for k, d in var.folder_delegations : k if d.role == "roles/owner"]
}

# Folder-level delegation (e.g. delegate the Networking folder to the network team).
resource "google_folder_iam_member" "this" {
  for_each = var.folder_delegations

  folder = each.value.folder
  role   = each.value.role
  member = each.value.member

  lifecycle {
    precondition {
      condition     = length(local.owner_delegations) == 0
      error_message = "Folder delegations must not grant roles/owner: ${join(", ", local.owner_delegations)}."
    }
  }
}

# Subnet-level Shared VPC delegation: grant networkUser on a specific subnet only.
resource "google_compute_subnetwork_iam_member" "this" {
  for_each = var.subnet_delegations

  project    = each.value.project
  region     = each.value.region
  subnetwork = each.value.subnetwork
  role       = each.value.role
  member     = each.value.member
}
