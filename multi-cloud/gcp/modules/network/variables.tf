variable "name" {
  description = "Logical name of this VPC, e.g. \"hub\" or \"prod\"."
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to network/subnet/firewall names."
  type        = string
  default     = "lz-"
}

variable "project" {
  description = "Project that hosts the VPC (the Shared VPC host project for spokes)."
  type        = string
}

variable "subnets" {
  description = "Subnets keyed by name; each is a region + primary CIDR within the VPC."
  type = map(object({
    region        = string
    ip_cidr_range = string
  }))
}
