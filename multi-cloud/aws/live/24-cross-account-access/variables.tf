variable "region" {
  description = "AWS region for target account resources."
  type        = string
  default     = "us-east-1"
}

variable "oidc_providers" {
  description = "OIDC providers for workload identity federation."
  type = map(object({
    url             = string
    client_id_list  = list(string)
    thumbprint_list = list(string)
    tags            = optional(map(string), {})
  }))
  default = {}
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
}

variable "resource_shares" {
  description = "AWS RAM resource shares to create from this account."
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
