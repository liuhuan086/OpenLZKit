variable "name_prefix" {
  description = "Prefix applied to cross-account role, OIDC provider and resource share names."
  type        = string
  default     = ""
}

variable "max_session_duration" {
  description = "Max assume-role session duration in seconds."
  type        = number
  default     = 3600
}

variable "access_roles" {
  description = "Cross-account IAM roles to create in the target account."
  type = map(object({
    role_name                = string
    description              = optional(string, "")
    trusted_principal_arns   = optional(list(string), [])
    federated_principal_arns = optional(list(string), [])
    oidc_provider_keys       = optional(list(string), [])
    external_id              = optional(string, null)
    condition                = optional(any, null)
    oidc_condition           = optional(any, null)
    managed_policy_arns      = optional(list(string), [])
    inline_policies          = optional(map(string), {})
    tags                     = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, role in var.access_roles :
      length(role.trusted_principal_arns) + length(role.federated_principal_arns) + length(role.oidc_provider_keys) > 0
    ])
    error_message = "Each cross-account role must define at least one trusted principal, federated principal or oidc_provider_key."
  }

  validation {
    condition = alltrue(flatten([
      for _, role in var.access_roles : concat(
        [for principal in role.trusted_principal_arns : principal != "*"],
        [for principal in role.federated_principal_arns : principal != "*"]
      )
    ]))
    error_message = "Cross-account role trusted principals must not contain wildcard principals."
  }

  validation {
    condition = alltrue(flatten([
      for _, role in var.access_roles : [
        for _, policy in role.inline_policies : can(jsondecode(policy))
      ]
    ]))
    error_message = "Each inline policy document must be valid JSON."
  }
}

variable "oidc_providers" {
  description = "OIDC providers for workload identity federation, keyed by stable identifier."
  type = map(object({
    url             = string
    client_id_list  = list(string)
    thumbprint_list = list(string)
    tags            = optional(map(string), {})
  }))
  default = {}
}

variable "resource_shares" {
  description = "AWS RAM resource shares keyed by stable identifier."
  type = map(object({
    name                      = string
    allow_external_principals = optional(bool, false)
    permission_arns           = optional(list(string), [])
    principals                = optional(list(string), [])
    resource_arns             = optional(list(string), [])
    tags                      = optional(map(string), {})
  }))
  default = {}
}

variable "common_tags" {
  description = "Tags merged onto created roles, OIDC providers and resource shares."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
