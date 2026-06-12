variable "name_prefix" {
  description = "Prefix applied to every RAM role name (naming convention)."
  type        = string
  default     = "lz-"
}

variable "max_session_duration" {
  description = "Max assume-role session duration in seconds."
  type        = number
  default     = 3600
}

variable "roles" {
  description = <<-EOT
    Assumable RAM roles, keyed by logical name. People reach these via SSO/federation;
    machines via OIDC — long-lived RAM users are intentionally not modeled here.
    `trusted_principals` are RAM principal ARNs allowed to assume the role
    (e.g. "acs:ram::<account-id>:root"); `system_policies` are Alibaba system
    policy names to attach.
  EOT
  type = map(object({
    description        = optional(string, "")
    trusted_principals = list(string)
    system_policies    = optional(list(string), [])
  }))
}
