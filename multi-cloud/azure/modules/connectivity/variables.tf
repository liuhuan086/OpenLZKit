variable "name_prefix" {
  description = "Prefix applied to peering names."
  type        = string
  default     = "lz-"
}

variable "peerings" {
  description = <<-EOT
    VNet peerings keyed by stable id. Create explicit entries only for allowed
    paths (hub<->spoke); omit denied paths (sandbox<->prod) so they stay isolated.
    `gateway_transit`/`use_remote_gateways` wire the hub gateway to spokes.
  EOT
  type = map(object({
    resource_group_name          = string
    virtual_network_name         = string
    remote_virtual_network_id    = string
    allow_forwarded_traffic      = optional(bool, false)
    allow_gateway_transit        = optional(bool, false)
    use_remote_gateways          = optional(bool, false)
    allow_virtual_network_access = optional(bool, true)
  }))
  default = {}
}
