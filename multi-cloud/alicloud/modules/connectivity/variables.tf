variable "name_prefix" {
  description = "Prefix applied to CEN, Transit Router and attachment names."
  type        = string
  default     = ""
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

variable "cen_name" {
  description = "CEN instance name when create_cen is true."
  type        = string
  default     = "landing-zone"
}

variable "cen_description" {
  description = "CEN instance description."
  type        = string
  default     = "Landing Zone CEN hub."
}

variable "transit_router_name" {
  description = "Transit Router name."
  type        = string
  default     = "hub"
}

variable "support_multicast" {
  description = "Enable Transit Router multicast support."
  type        = bool
  default     = false
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

  validation {
    condition     = alltrue([for _, attachment in var.vpc_attachments : length(attachment.zone_mappings) > 0])
    error_message = "Each VPC attachment must include at least one zone_mapping."
  }
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
    route_table_key      = string
    destination_cidr     = string
    next_hop_type        = string
    attachment_key       = optional(string, null)
    next_hop_id          = optional(string, null)
    name                 = optional(string, null)
    description          = optional(string, null)
  }))
  default = {}
}

variable "common_tags" {
  description = "Tags merged onto created CEN/TR resources."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
