variable "name_prefix" {
  description = "Prefix applied to CAM policy/role names."
  type        = string
  default     = "lz-"
}

variable "custom_policies" {
  description = "Custom CAM policies keyed by stable id. `document` is a CAM policy JSON string."
  type = map(object({
    document    = string
    description = optional(string, "")
  }))
  default = {}
}

variable "roles" {
  description = <<-EOT
    CAM roles keyed by stable id. `document` is the assume-role trust policy JSON.
    `custom_policy_keys` references keys from `custom_policies` to attach.
  EOT
  type = map(object({
    document           = string
    description        = optional(string, "")
    session_duration   = optional(number, 3600)
    custom_policy_keys = optional(list(string), [])
  }))
  default = {}
}
