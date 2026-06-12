variable "subscription_id" {
  description = "Azure subscription id for the provider."
  type        = string
}

variable "root_scope_id" {
  description = "Scope where custom roles are defined and assignable (e.g. the root/platform management group resource id)."
  type        = string
}

variable "role_assignments" {
  description = "Optional RBAC assignments. Empty by default because principal ids are environment-specific."
  type = map(object({
    scope                = string
    principal_id         = string
    principal_type       = optional(string)
    role_definition_name = optional(string)
    custom_role_key      = optional(string)
    description          = optional(string)
  }))
  default = {}
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# 20-identity: least-privilege custom roles for platform personas. Assignments
# to Entra groups are supplied per environment via role_assignments.
module "identity" {
  source      = "../../modules/identity"
  name_prefix = "lz-"

  custom_roles = {
    platform-operator = {
      description       = "Operate platform infrastructure without managing RBAC or policy."
      scope             = var.root_scope_id
      assignable_scopes = [var.root_scope_id]
      actions           = ["*/read", "Microsoft.Resources/deployments/*", "Microsoft.Network/*"]
      not_actions       = ["Microsoft.Authorization/*/write", "Microsoft.Authorization/elevateAccess/Action"]
    }
    security-auditor = {
      description       = "Read-only access for security and audit."
      scope             = var.root_scope_id
      assignable_scopes = [var.root_scope_id]
      actions           = ["*/read"]
    }
  }

  role_assignments = var.role_assignments
}

output "custom_role_ids" {
  value = module.identity.custom_role_ids
}
