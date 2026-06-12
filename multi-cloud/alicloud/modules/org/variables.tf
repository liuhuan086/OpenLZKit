variable "name_prefix" {
  description = "Prefix applied to every folder name, e.g. \"lz-\". Enforces a consistent naming convention across the Resource Directory."
  type        = string
  default     = ""
}

variable "folders" {
  description = <<-EOT
    Folder hierarchy created directly under the Resource Directory root.
    The map key is a stable identifier (used to reference the folder from `accounts`);
    `display_name` is the human-readable folder name; `children` defines one optional
    level of nested sub-folders.
  EOT
  type = map(object({
    display_name = string
    children     = optional(map(object({ display_name = string })), {})
  }))
}

variable "accounts" {
  description = <<-EOT
    Resource Directory member accounts to create, keyed by a stable identifier.
    `folder_key` references a key from `folders` (top-level or "<parent>/<child>").
    Empty by default: creating member accounts has billing impact and should be
    enabled deliberately.
  EOT
  type = map(object({
    display_name = string
    folder_key   = string
    tags         = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  description = "Tags merged onto every created member account. Folders do not support tags in Alibaba Cloud."
  type        = map(string)
  default     = {}
}
