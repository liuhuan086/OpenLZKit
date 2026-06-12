variable "host_project_id" {
  description = "Shared VPC host project id where the networks live."
  type        = string
}

variable "region" {
  description = "Default region for the subnets."
  type        = string
  default     = "us-central1"
}

provider "google" {
  project = var.host_project_id
}

# Hub-Spoke baseline with non-overlapping CIDRs. Shared VPC service-project
# attachment and NCC are layered in live/35-connectivity.
module "hub" {
  source  = "../../modules/network"
  name    = "hub"
  project = var.host_project_id
  subnets = {
    shared = { region = var.region, ip_cidr_range = "10.0.0.0/20" }
  }
}

module "dev" {
  source  = "../../modules/network"
  name    = "dev"
  project = var.host_project_id
  subnets = {
    workload = { region = var.region, ip_cidr_range = "10.10.0.0/20" }
  }
}

module "prod" {
  source  = "../../modules/network"
  name    = "prod"
  project = var.host_project_id
  subnets = {
    workload = { region = var.region, ip_cidr_range = "10.30.0.0/20" }
  }
}

output "network_ids" {
  description = "VPC network ids by tier."
  value = {
    hub  = module.hub.network_id
    dev  = module.dev.network_id
    prod = module.prod.network_id
  }
}
