variable "name" {
  description = "Logical name of this VPC, e.g. \"hub\" or \"prod\". Used in resource names."
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to VPC/VSwitch/SG names (naming convention)."
  type        = string
  default     = "lz-"
}

variable "cidr_block" {
  description = "VPC CIDR block. Must not overlap other VPCs in the Landing Zone."
  type        = string
}

variable "vswitches" {
  description = "VSwitches keyed by logical name; each is a zone + sub-CIDR within the VPC CIDR."
  type = map(object({
    zone_id    = string
    cidr_block = string
  }))
}

variable "tags" {
  description = "Tags applied to all network resources."
  type        = map(string)
  default     = {}
}
