variable "name_prefix" {
  description = "Prefix applied to every Organizations policy name."
  type        = string
  default     = ""
}

variable "policies" {
  description = "AWS Organizations policies keyed by stable identifier."
  type = map(object({
    name        = string
    description = optional(string, null)
    type        = string
    content     = string
    tags        = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, policy in var.policies :
      contains(["SERVICE_CONTROL_POLICY", "TAG_POLICY"], policy.type)
    ])
    error_message = "Each policy type must be SERVICE_CONTROL_POLICY or TAG_POLICY."
  }

  validation {
    condition     = alltrue([for _, policy in var.policies : can(jsondecode(policy.content))])
    error_message = "Each policy content value must be valid JSON."
  }
}

variable "attachments" {
  description = "Organizations policy attachments keyed by stable identifier."
  type = map(object({
    policy_key = string
    target_id  = string
  }))
  default = {}
}

variable "common_tags" {
  description = "Tags merged onto every Organizations policy."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
