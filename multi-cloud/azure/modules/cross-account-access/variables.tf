variable "name_prefix" {
  description = "Prefix applied to managed identity names."
  type        = string
  default     = "lz-"
}

variable "managed_identities" {
  description = <<-EOT
    User-assigned managed identities (machine identities), keyed by stable id.
    Each may declare federated credentials (e.g. GitHub OIDC) so no secret is stored.
  EOT
  type = map(object({
    resource_group_name = string
    location            = string
    federated_credentials = optional(map(object({
      issuer   = string
      subject  = string
      audience = optional(list(string), ["api://AzureADTokenExchange"])
    })), {})
  }))
  default = {}
}

variable "role_assignments" {
  description = <<-EOT
    Cross-subscription RBAC assignments, keyed by stable id. `scope` is the target
    (another subscription/resource). Set `managed_identity_key` (machine) or
    `principal_id` (Entra group/SP). Keep roles least-privilege.
  EOT
  type = map(object({
    scope                = string
    role_definition_name = string
    managed_identity_key = optional(string)
    principal_id         = optional(string)
    principal_type       = optional(string)
    description          = optional(string)
    condition            = optional(string)
    condition_version    = optional(string)
  }))
  default = {}
}
