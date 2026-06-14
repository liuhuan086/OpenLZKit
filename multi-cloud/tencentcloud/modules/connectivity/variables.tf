variable "name_prefix" {
  description = "Prefix applied to the CCN name."
  type        = string
  default     = "lz-"
}

variable "ccn_name" {
  description = "Cloud Connect Network (CCN) name."
  type        = string
  default     = "hub"
}

variable "description" {
  description = "CCN description."
  type        = string
  default     = "Landing Zone hub CCN."
}

variable "tags" {
  description = "Tags applied to the CCN."
  type        = map(string)
  default     = {}
}

variable "attachments" {
  description = <<-EOT
    VPCs to attach to the CCN, keyed by stable id. Attach only VPCs that should
    interconnect — keep isolated tiers (sandbox) off the CCN.
  EOT
  type = map(object({
    instance_id     = string
    instance_region = string
  }))
  default = {}
}
