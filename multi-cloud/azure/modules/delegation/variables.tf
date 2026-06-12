variable "name_prefix" {
  description = "Prefix applied to Lighthouse definition names."
  type        = string
  default     = "lz-"
}

variable "delegations" {
  description = <<-EOT
    Azure Lighthouse delegations keyed by stable id. `scope` is the delegated
    subscription/resource group; `managing_tenant_id` is the platform tenant.
    `authorizations` grant managing-tenant principals least-privilege roles —
    do NOT grant Owner.
  EOT
  type = map(object({
    name               = string
    description        = optional(string, "")
    managing_tenant_id = string
    scope              = string
    authorizations = list(object({
      principal_id                  = string
      role_definition_id            = string
      principal_display_name        = optional(string)
      delegated_role_definition_ids = optional(list(string))
    }))
  }))
  default = {}
}
