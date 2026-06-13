variable "folder_delegations" {
  description = <<-EOT
    Folder-level IAM delegations keyed by stable id (delegate management of a
    folder to a team). `role` must not be roles/owner.
  EOT
  type = map(object({
    folder = string
    role   = string
    member = string
  }))
  default = {}
}

variable "subnet_delegations" {
  description = <<-EOT
    Shared VPC subnet-level IAM, keyed by stable id. Grants a service-project
    principal `networkUser` on a specific subnet (least-privilege network sharing).
  EOT
  type = map(object({
    project    = string
    region     = string
    subnetwork = string
    member     = string
    role       = optional(string, "roles/compute.networkUser")
  }))
  default = {}
}
