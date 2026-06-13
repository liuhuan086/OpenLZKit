variable "customer_id" {
  description = "Cloud Identity customer id as a parent (\"customers/C0xxxxxxx\")."
  type        = string
}

variable "groups" {
  description = <<-EOT
    Cloud Identity security groups (access personas) keyed by stable id. People
    are added to groups via the IdP; groups receive IAM, not users.
  EOT
  type = map(object({
    email        = string
    display_name = optional(string)
    description  = optional(string)
  }))
  default = {}
}

variable "folder_bindings" {
  description = "IAM bindings granting a group a role at folder scope (\"folders/<id>\")."
  type = map(object({
    group_key = string
    folder    = string
    role      = string
  }))
  default = {}
}

variable "project_bindings" {
  description = "IAM bindings granting a group a role at project scope."
  type = map(object({
    group_key = string
    project   = string
    role      = string
  }))
  default = {}
}
