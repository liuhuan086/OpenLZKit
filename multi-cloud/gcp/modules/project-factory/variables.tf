variable "projects" {
  description = <<-EOT
    Projects to create, keyed by a stable id. `folder_id` is a folder resource
    name ("folders/<number>"). Empty by default: creating projects has billing
    impact and should be enabled deliberately. The insecure default network is
    never created (auto_create_network is forced to false).
  EOT
  type = map(object({
    name            = string
    project_id      = string
    folder_id       = string
    billing_account = optional(string)
    labels          = optional(map(string), {})
  }))
  default = {}
}

variable "common_labels" {
  description = "Labels merged onto every created project."
  type        = map(string)
  default     = {}
}
