variable "projects" {
  description = <<-EOT
    Projects to create, keyed by a stable id. `folder_id` is a folder resource
    name ("folders/<number>"). Empty by default: creating projects has billing
    impact and should be enabled deliberately. `auto_create_network` is false so
    no insecure default network is created.
  EOT
  type = map(object({
    name                = string
    project_id          = string
    folder_id           = string
    billing_account     = optional(string)
    auto_create_network = optional(bool, false)
    labels              = optional(map(string), {})
  }))
  default = {}
}

variable "common_labels" {
  description = "Labels merged onto every created project."
  type        = map(string)
  default     = {}
}
