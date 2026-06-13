resource "google_compute_shared_vpc_host_project" "host" {
  project = var.host_project
}

resource "google_compute_shared_vpc_service_project" "this" {
  for_each = var.service_projects

  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = each.value.service_project
}
