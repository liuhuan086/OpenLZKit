variable "members" {
  description = <<-EOT
    Organization member accounts to create, keyed by stable id. `node_id` is the
    organization node to place the member in. Empty by default: creating members
    has billing impact and should be enabled deliberately.
  EOT
  type = map(object({
    name           = string
    node_id        = number
    policy_type    = optional(string, "Financial")
    permission_ids = list(number)
    tags           = optional(map(string), {})
  }))
  default = {}
}

variable "common_tags" {
  description = "Tags merged onto every created member account."
  type        = map(string)
  default     = {}
}
