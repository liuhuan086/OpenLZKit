variable "org_id" {
  description = "Organization id (numeric) for custom org roles. Required if custom_org_roles is non-empty."
  type        = string
  default     = null
}

variable "custom_org_roles" {
  description = <<-EOT
    Custom organization IAM roles keyed by role_id. Keep `permissions`
    least-privilege; `stage` is GA/BETA/ALPHA.
  EOT
  type = map(object({
    title       = string
    description = optional(string, "")
    permissions = list(string)
    stage       = optional(string, "GA")
  }))
  default = {}
}

variable "folder_bindings" {
  description = "IAM member bindings at folder scope, keyed by stable id (folder = \"folders/<id>\")."
  type = map(object({
    folder = string
    role   = string
    member = string
  }))
  default = {}
}

variable "project_bindings" {
  description = "IAM member bindings at project scope, keyed by stable id."
  type = map(object({
    project = string
    role    = string
    member  = string
  }))
  default = {}
}
