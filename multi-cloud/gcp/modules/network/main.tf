resource "google_compute_network" "this" {
  name                    = "${var.name_prefix}${var.name}"
  project                 = var.project
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "this" {
  for_each = var.subnets

  name                     = "${var.name_prefix}${var.name}-${each.key}"
  project                  = var.project
  network                  = google_compute_network.this.id
  region                   = each.value.region
  ip_cidr_range            = each.value.ip_cidr_range
  private_ip_google_access = true

  # VPC flow logs for audit/forensics.
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Explicit default-deny ingress (GCP also denies inbound by default). Workloads
# add narrowly-scoped higher-priority allow rules; public ingress is never default.
resource "google_compute_firewall" "deny_all_ingress" {
  name      = "${var.name_prefix}${var.name}-deny-all-ingress"
  project   = var.project
  network   = google_compute_network.this.name
  direction = "INGRESS"
  priority  = 65534

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
