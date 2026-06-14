variable "name_prefix" {
  description = "Prefix applied to share unit names."
  type        = string
  default     = "lz-"
}

variable "share_units" {
  description = "Organization share units (resource sharing), keyed by stable id."
  type = map(object({
    name        = string
    area        = string
    description = optional(string, "")
  }))
  default = {}
}

variable "shared_resources" {
  description = <<-EOT
    Resources shared into a share unit, keyed by stable id. `unit_key` references a
    key from `share_units`; `product_resource_id` and `type` identify the resource.
  EOT
  type = map(object({
    unit_key            = string
    area                = string
    product_resource_id = string
    type                = string
  }))
  default = {}
}

variable "member_delegations" {
  description = <<-EOT
    Member auth-policy delegations keyed by stable id (delegate management to a
    member sub-account). `policy_id` must be a least-privilege policy, never full access.
  EOT
  type = map(object({
    org_sub_account_uin = string
    policy_id           = number
  }))
  default = {}
}
