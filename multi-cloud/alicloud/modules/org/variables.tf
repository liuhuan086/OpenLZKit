variable "name_prefix" {
  description = "Prefix applied to every folder name, e.g. \"lz-\". Enforces a consistent naming convention across the Resource Directory."
  type        = string
  default     = ""
}

variable "folders" {
  description = <<-EOT
    Folder hierarchy created directly under the Resource Directory root.
    The map key is a stable identifier (folder ids are exposed via `folder_ids`
    for placing accounts with modules/account-factory); `display_name` is the
    human-readable folder name; `children` defines one optional level of sub-folders.
  EOT
  type = map(object({
    display_name = string
    children     = optional(map(object({ display_name = string })), {})
  }))
}
