variable "name_prefix" {
  description = "Prefix applied to network resource names."
  type        = string
  default     = ""
}

variable "vpc" {
  description = "VPC baseline configuration."
  type = object({
    name                             = string
    cidr_block                       = string
    assign_generated_ipv6_cidr_block = optional(bool, false)
    enable_dns_hostnames             = optional(bool, true)
    enable_dns_support               = optional(bool, true)
    instance_tenancy                 = optional(string, "default")
    tags                             = optional(map(string), {})
  })
}

variable "subnets" {
  description = "Subnets keyed by stable identifier."
  type = map(object({
    name                    = string
    cidr_block              = string
    availability_zone       = optional(string, null)
    availability_zone_id    = optional(string, null)
    map_public_ip_on_launch = optional(bool, false)
    route_table_key         = string
    tags                    = optional(map(string), {})
  }))
  default = {}
}

variable "route_tables" {
  description = "Route tables keyed by stable identifier."
  type = map(object({
    name = string
    routes = optional(list(object({
      cidr_block             = optional(string, null)
      ipv6_cidr_block        = optional(string, null)
      gateway_key            = optional(string, null)
      nat_gateway_key        = optional(string, null)
      transit_gateway_id     = optional(string, null)
      egress_only_gateway_id = optional(string, null)
      network_interface_id   = optional(string, null)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "create_internet_gateway" {
  description = "Create an Internet Gateway for the VPC."
  type        = bool
  default     = false
}

variable "nat_gateways" {
  description = "NAT gateways keyed by stable identifier."
  type = map(object({
    name              = string
    public_subnet_key = string
    connectivity_type = optional(string, "public")
    tags              = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for _, nat in var.nat_gateways : contains(keys(var.subnets), nat.public_subnet_key)])
    error_message = "Each NAT gateway public_subnet_key must exist in var.subnets."
  }
}

variable "vpc_endpoints" {
  description = "VPC endpoints keyed by stable identifier."
  type = map(object({
    service_name        = string
    vpc_endpoint_type   = optional(string, "Interface")
    subnet_keys         = optional(list(string), [])
    route_table_keys    = optional(list(string), [])
    security_group_keys = optional(list(string), [])
    private_dns_enabled = optional(bool, true)
    policy              = optional(string, null)
    tags                = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for _, endpoint in var.vpc_endpoints : [
        for subnet_key in endpoint.subnet_keys : contains(keys(var.subnets), subnet_key)
      ]
    ]))
    error_message = "Each VPC endpoint subnet_key must exist in var.subnets."
  }

  validation {
    condition = alltrue(flatten([
      for _, endpoint in var.vpc_endpoints : [
        for route_table_key in endpoint.route_table_keys : contains(keys(var.route_tables), route_table_key)
      ]
    ]))
    error_message = "Each VPC endpoint route_table_key must exist in var.route_tables."
  }
}

variable "security_groups" {
  description = "Security groups keyed by stable identifier."
  type = map(object({
    name        = string
    description = optional(string, "Managed by OpenLZKit")
    ingress = optional(list(object({
      description      = optional(string, null)
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = optional(list(string), [])
      ipv6_cidr_blocks = optional(list(string), [])
      security_groups  = optional(list(string), [])
      self             = optional(bool, false)
    })), [])
    egress = optional(list(object({
      description      = optional(string, null)
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = optional(list(string), [])
      ipv6_cidr_blocks = optional(list(string), [])
      security_groups  = optional(list(string), [])
      self             = optional(bool, false)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "flow_logs" {
  description = "VPC Flow Logs keyed by stable identifier."
  type = map(object({
    log_destination      = string
    log_destination_type = string
    traffic_type         = optional(string, "ALL")
    iam_role_arn         = optional(string, null)
    log_format           = optional(string, null)
    tags                 = optional(map(string), {})
  }))
  default = {}
}

variable "common_tags" {
  description = "Tags merged onto all supported network resources."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
