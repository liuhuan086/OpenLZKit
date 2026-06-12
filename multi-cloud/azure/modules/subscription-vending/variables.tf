variable "associations" {
  description = <<-EOT
    Associate EXISTING subscriptions to management groups, keyed by a stable id.
    Use this when subscriptions are created out-of-band (EA/MCA portal) and only
    need to be placed in the hierarchy.
  EOT
  type = map(object({
    management_group_id = string
    subscription_id     = string
  }))
  default = {}
}

variable "subscriptions" {
  description = <<-EOT
    Create new subscriptions (alias) under a billing scope, keyed by alias.
    Empty by default: creating subscriptions has billing impact and requires an
    MCA/EA billing scope, so enable it deliberately.
  EOT
  type = map(object({
    subscription_name = string
    billing_scope_id  = string
    workload          = optional(string, "Production")
    tags              = optional(map(string), {})
  }))
  default = {}
}

variable "common_tags" {
  description = "Tags merged onto every created subscription."
  type        = map(string)
  default     = {}
}
