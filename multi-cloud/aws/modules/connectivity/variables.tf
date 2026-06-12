variable "name_prefix" {
  description = "Prefix applied to Transit Gateway, route table and RAM share names."
  type        = string
  default     = ""
}

variable "create_transit_gateway" {
  description = "Create a new Transit Gateway. Set false to manage route tables and attachments for an existing TGW."
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

  validation {
    condition = alltrue([
      for _, attachment in var.vpc_attachments :
      contains(keys(var.route_tables), attachment.route_table_key)
    ])
    error_message = "Each VPC attachment route_table_key must exist in var.route_tables."
  }

  validation {
    condition = alltrue(flatten([
      for _, attachment in var.vpc_attachments : [
        for route_table_key in attachment.propagate_to_keys : contains(keys(var.route_tables), route_table_key)
      ]
    ]))
    error_message = "Each VPC attachment propagate_to_keys value must exist in var.route_tables."
  }
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

  validation {
    condition     = alltrue([for _, route in var.routes : contains(keys(var.route_tables), route.route_table_key)])
    error_message = "Each route route_table_key must exist in var.route_tables."
  }
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

variable "common_tags" {
  description = "Tags merged onto created connectivity resources."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
