variable "name" {
  description = "Logical name of this VNet, e.g. \"hub\" or \"prod\"."
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to VNet/NSG names."
  type        = string
  default     = "lz-"
}

variable "resource_group_name" {
  description = "Resource group to create the network resources in."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "address_space" {
  description = "VNet address space. Must not overlap other VNets in the Landing Zone."
  type        = list(string)
}

variable "subnets" {
  description = "Subnets keyed by name; each is a list of address prefixes within the VNet space."
  type = map(object({
    address_prefixes = list(string)
  }))
}

variable "tags" {
  description = "Tags applied to all network resources."
  type        = map(string)
  default     = {}
}
