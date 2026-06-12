variable "name_prefix" {
  description = "Prefix applied to every OU name."
  type        = string
  default     = ""
}

variable "organizational_units" {
  description = <<-EOT
    OU hierarchy created under the AWS Organizations root.
    Map keys are stable identifiers. Child keys are exposed as "<parent>/<child>".
    Keep this to one optional child level for predictable account placement.
  EOT
  type = map(object({
    name = string
    children = optional(map(object({
      name = string
      tags = optional(map(string), {})
    })), {})
    tags = optional(map(string), {})
  }))
}

variable "tags" {
  description = "Tags merged onto every created OU."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
