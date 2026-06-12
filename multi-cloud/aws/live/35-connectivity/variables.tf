variable "region" {
  description = "AWS region for connectivity resources."
  type        = string
  default     = "us-east-1"
}

variable "create_transit_gateway" {
  description = "Create a new Transit Gateway."
  type        = bool
  default     = true
}

variable "transit_gateway_id" {
  description = "Existing Transit Gateway id when create_transit_gateway is false."
  type        = string
  default     = null
}

variable "transit_gateway_arn" {
  description = "Existing Transit Gateway ARN for RAM sharing when create_transit_gateway is false."
  type        = string
  default     = null
}

variable "transit_gateway" {
  description = "Transit Gateway configuration."
  type = object({
    name                               = optional(string, "core")
    description                        = optional(string, "Landing Zone Transit Gateway")
    amazon_side_asn                    = optional(number, 64512)
    auto_accept_shared_attachments     = optional(string, "disable")
    default_route_table_association    = optional(string, "disable")
    default_route_table_propagation    = optional(string, "disable")
    dns_support                        = optional(string, "enable")
    multicast_support                  = optional(string, "disable")
    security_group_referencing_support = optional(string, "disable")
    transit_gateway_cidr_blocks        = optional(list(string), [])
    vpn_ecmp_support                   = optional(string, "enable")
    tags                               = optional(map(string), {})
  })
  default = {}
}

variable "route_tables" {
  description = "Transit Gateway route tables keyed by stable network zone."
  type = map(object({
    name = string
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "vpc_attachments" {
  description = "VPC attachments keyed by stable workload or network identifier."
  type = map(object({
    name                               = string
    vpc_id                             = string
    subnet_ids                         = list(string)
    route_table_key                    = string
    propagate_to_keys                  = optional(list(string), [])
    appliance_mode_support             = optional(string, "disable")
    dns_support                        = optional(string, "enable")
    ipv6_support                       = optional(string, "disable")
    security_group_referencing_support = optional(string, "disable")
    tags                               = optional(map(string), {})
  }))
  default = {}
}

variable "routes" {
  description = "Explicit Transit Gateway routes keyed by stable identifier."
  type = map(object({
    route_table_key        = string
    destination_cidr_block = string
    attachment_key         = optional(string, null)
    blackhole              = optional(bool, false)
  }))
  default = {}
}

variable "ram_shares" {
  description = "AWS RAM shares for the Transit Gateway or additional network resources."
  type = map(object({
    name                      = string
    allow_external_principals = optional(bool, false)
    principals                = optional(list(string), [])
    permission_arns           = optional(list(string), [])
    resource_arns             = optional(list(string), [])
    share_transit_gateway     = optional(bool, true)
    tags                      = optional(map(string), {})
  }))
  default = {}
}
