variable "name_prefix" {
  description = "Prefix applied to every control policy name."
  type        = string
  default     = ""
}

variable "policies" {
  description = "Resource Directory control policies keyed by stable identifier."
  type = map(object({
    name            = string
    description     = optional(string, null)
    effect_scope    = string
    policy_document = string
    tags            = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for _, policy in var.policies : can(jsondecode(policy.policy_document))])
    error_message = "Each control policy policy_document must be valid JSON."
  }
}

variable "attachments" {
  description = "Control policy attachments keyed by stable identifier."
  type = map(object({
    policy_key = string
    target_id  = string
  }))
  default = {}
}

variable "common_tags" {
  description = "Tags merged onto every control policy."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
