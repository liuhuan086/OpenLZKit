variable "ou_ids" {
  description = "Map of OU key to AWS Organizations OU id, usually from modules/org.ou_ids."
  type        = map(string)
}

variable "accounts" {
  description = <<-EOT
    AWS Organizations accounts to create, keyed by stable identifier.
    Empty by default because account vending creates real AWS accounts and must
    be explicitly approved.
  EOT
  type = map(object({
    name                       = string
    email                      = string
    ou_key                     = string
    role_name                  = optional(string, "OrganizationAccountAccessRole")
    iam_user_access_to_billing = optional(string, "DENY")
    close_on_deletion          = optional(bool, false)
    tags                       = optional(map(string), {})
  }))
  default = {}
}

variable "required_tag_keys" {
  description = "Required governance tag keys for every vended account."
  type        = list(string)
  default     = ["owner", "cost_center", "env", "project", "managed_by", "data_classification"]
}

variable "common_tags" {
  description = "Tags merged onto every account."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}
