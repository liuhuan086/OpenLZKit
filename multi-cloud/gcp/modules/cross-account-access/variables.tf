variable "service_accounts" {
  description = <<-EOT
    Service accounts (machine identities) keyed by stable id. Prefer Workload
    Identity Federation impersonation over downloading keys.
  EOT
  type = map(object({
    account_id   = string
    project      = string
    display_name = optional(string)
    description  = optional(string)
  }))
  default = {}
}

variable "project_bindings" {
  description = <<-EOT
    Cross-project IAM member bindings keyed by stable id. Set `service_account_key`
    (a key from `service_accounts`) or an explicit `member`. Keep roles least-privilege.
  EOT
  type = map(object({
    project             = string
    role                = string
    service_account_key = optional(string)
    member              = optional(string)
  }))
  default = {}
}

variable "wif_bindings" {
  description = <<-EOT
    Workload Identity Federation impersonation bindings keyed by stable id.
    `member` is a principalSet (repo-scoped) allowed to impersonate the service
    account referenced by `service_account_key`.
  EOT
  type = map(object({
    service_account_key = string
    member              = string
  }))
  default = {}
}
