variable "name_prefix" {
  description = "Prefix applied to every member account display name."
  type        = string
  default     = ""
}

variable "folder_ids" {
  description = "Map of folder key to Resource Directory folder id, usually from modules/org.folder_ids."
  type        = map(string)
}

variable "accounts" {
  description = <<-EOT
    Resource Directory member accounts to create, keyed by stable identifier.
    `folder_key` references a key in `folder_ids`. Empty by default because
    creating accounts has billing and governance impact.
  EOT
  type = map(object({
    display_name = string
    folder_key   = string
    tags         = optional(map(string), {})
  }))
  default = {}
}

variable "common_tags" {
  description = "Tags merged onto every created member account."
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}

variable "required_tag_keys" {
  description = "Required FinOps tag keys for every member account."
  type        = list(string)
  default     = ["owner", "cost_center", "env", "project", "managed_by", "data_classification"]
}
