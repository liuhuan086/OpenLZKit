variable "host_project" {
  description = "Project to enable as the Shared VPC host."
  type        = string
}

variable "service_projects" {
  description = <<-EOT
    Service projects to attach to the Shared VPC host, keyed by stable id. Attach
    only projects that should share the host network — keep isolated tiers (e.g.
    sandbox) off the production host.
  EOT
  type = map(object({
    service_project = string
  }))
  default = {}
}
