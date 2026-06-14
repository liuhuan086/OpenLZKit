variable "name_prefix" {
  description = "Prefix applied to manage policy names."
  type        = string
  default     = "lz-"
}

variable "policies" {
  description = <<-EOT
    Organization manage policies (SCP-equivalent) keyed by stable id. `content` is
    a policy JSON string; `type` defaults to SERVICE_CONTROL_POLICY.
  EOT
  type = map(object({
    content     = string
    description = optional(string, "")
    type        = optional(string, "SERVICE_CONTROL_POLICY")
  }))
  default = {}
}

variable "attachments" {
  description = <<-EOT
    Manage policy attachments keyed by stable id. `policy_key` references a key
    from `policies`; `target_type` is NODE or MEMBER.
  EOT
  type = map(object({
    policy_key  = string
    target_id   = number
    target_type = string
  }))
  default = {}
}
