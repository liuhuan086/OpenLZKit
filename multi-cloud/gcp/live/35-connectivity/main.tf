variable "project_id" {
  description = "Project id for the provider."
  type        = string
}

variable "host_project" {
  description = "Shared VPC host project (from 30-network)."
  type        = string
}

variable "service_projects" {
  description = "Service projects to attach to the Shared VPC host. Empty by default; never attach sandbox to the prod host."
  type = map(object({
    service_project = string
  }))
  default = {}
}

provider "google" {
  project = var.project_id
}

# 35-connectivity: enable the Shared VPC host and attach service projects. Only
# attach projects that should share the host network; isolated tiers stay off.
module "connectivity" {
  source           = "../../modules/connectivity"
  host_project     = var.host_project
  service_projects = var.service_projects
}

output "host_project" {
  value = module.connectivity.host_project
}
