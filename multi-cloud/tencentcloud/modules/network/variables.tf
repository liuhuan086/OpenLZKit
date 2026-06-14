variable "name" {
  description = "Logical name of this VPC, e.g. \"hub\" or \"prod\"."
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to VPC/subnet/security-group names."
  type        = string
  default     = "lz-"
}

variable "cidr_block" {
  description = "VPC CIDR block. Must not overlap other VPCs in the Landing Zone."
  type        = string
}

variable "subnets" {
  description = "Subnets keyed by name; each is an availability zone + CIDR within the VPC."
  type = map(object({
    availability_zone = string
    cidr_block        = string
  }))
}

variable "tags" {
  description = "Tags applied to network resources."
  type        = map(string)
  default     = {}
}
