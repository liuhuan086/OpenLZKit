variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

variable "create_cen" {
  description = "Create a CEN instance. Set false to use existing_cen_id."
  type        = bool
  default     = true
}

variable "existing_cen_id" {
  description = "Existing CEN instance id when create_cen is false."
  type        = string
  default     = null
}

variable "route_tables" {
  description = "Transit Router route tables keyed by stable identifier."
  type = map(object({
    name        = string
    description = optional(string, "")
    tags        = optional(map(string), {})
  }))
  default = {}
}

variable "vpc_attachments" {
  description = "Transit Router VPC attachments keyed by stable identifier."
  type = map(object({
    name                       = string
    vpc_id                     = string
    vpc_owner_id               = optional(string, null)
    auto_publish_route_enabled = optional(bool, false)
    force_delete               = optional(bool, false)
    zone_mappings = list(object({
      zone_id    = string
      vswitch_id = string
    }))
    route_table_association_key = optional(string, null)
    route_table_propagation_key = optional(string, null)
    tags                        = optional(map(string), {})
  }))
  default = {}
}

variable "grant_attachments" {
  description = "Cross-account grants allowing a CEN owner to attach external network instances."
  type = map(object({
    cen_owner_id  = string
    instance_id   = string
    instance_type = string
  }))
  default = {}
}

variable "route_entries" {
  description = "Explicit Transit Router route entries keyed by stable identifier."
  type = map(object({
    route_table_key  = string
    destination_cidr = string
    next_hop_type    = string
    attachment_key   = optional(string, null)
    next_hop_id      = optional(string, null)
    name             = optional(string, null)
    description      = optional(string, null)
  }))
  default = {}
}

provider "alicloud" {
  region = var.region
}

module "connectivity" {
  source = "../../modules/connectivity"

  name_prefix       = "lz-"
  create_cen        = var.create_cen
  existing_cen_id   = var.existing_cen_id
  route_tables      = var.route_tables
  vpc_attachments   = var.vpc_attachments
  grant_attachments = var.grant_attachments
  route_entries     = var.route_entries
}

output "cen_id" {
  description = "CEN instance id."
  value       = module.connectivity.cen_id
}

output "transit_router_id" {
  description = "Transit Router id."
  value       = module.connectivity.transit_router_id
}

output "vpc_attachment_ids" {
  description = "Transit Router VPC attachment ids by key."
  value       = module.connectivity.vpc_attachment_ids
}
