variable "project_id" {
  description = "Project id for the provider."
  type        = string
}

variable "folder_delegations" {
  description = "Folder-level IAM delegations (e.g. delegate Networking folder to the network team). Empty by default."
  type = map(object({
    folder = string
    role   = string
    member = string
  }))
  default = {}
}

variable "subnet_delegations" {
  description = "Shared VPC subnet-level networkUser grants. Empty by default."
  type = map(object({
    project    = string
    region     = string
    subnetwork = string
    member     = string
    role       = optional(string, "roles/compute.networkUser")
  }))
  default = {}
}

provider "google" {
  project = var.project_id
}

# 55-delegation: least-privilege delegation (FP-8) — folder-level management
# delegation (never roles/owner) and subnet-level Shared VPC access.
module "delegation" {
  source             = "../../modules/delegation"
  folder_delegations = var.folder_delegations
  subnet_delegations = var.subnet_delegations
}

output "folder_delegation_ids" {
  value = module.delegation.folder_delegation_ids
}
