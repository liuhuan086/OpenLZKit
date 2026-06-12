variable "name_prefix" {
  description = "Prefix applied to every folder display name, e.g. \"lz-\"."
  type        = string
  default     = "lz-"
}

variable "parent" {
  description = "Parent of the top-level folders: \"organizations/<org_id>\" or \"folders/<folder_id>\"."
  type        = string
}

variable "folders" {
  description = <<-EOT
    Folder hierarchy. The map key is a stable id (used to reference the folder
    from other modules); `display_name` is the human-readable name; `children`
    defines one optional level of nested folders.
  EOT
  type = map(object({
    display_name = string
    children     = optional(map(object({ display_name = string })), {})
  }))
}
