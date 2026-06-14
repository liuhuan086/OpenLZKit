variable "name_prefix" {
  description = "Prefix applied to cross-account role names."
  type        = string
  default     = "lz-"
}

variable "access_roles" {
  description = <<-EOT
    Cross-account CAM roles keyed by stable id. `trusted_uins` are the root UINs of
    source accounts allowed to assume the role (via STS). `policy_ids` are CAM
    policy ids to attach. Keep policies least-privilege.
  EOT
  type = map(object({
    name             = string
    trusted_uins     = list(string)
    policy_ids       = optional(list(number), [])
    session_duration = optional(number, 3600)
    description      = optional(string, "")
  }))
  default = {}
}
