variable "name_prefix" {
  description = "Prefix applied to every organization node name, e.g. \"lz-\"."
  type        = string
  default     = "lz-"
}

variable "root_node_id" {
  description = "Organization root node id under which the top-level nodes are created."
  type        = number
}

variable "nodes" {
  description = <<-EOT
    Organization node hierarchy. The map key is a stable id (used to reference the
    node from other modules); `name` is the node name; `children` defines one
    optional level of nested nodes.
  EOT
  type = map(object({
    name     = string
    children = optional(map(object({ name = string })), {})
  }))
}

variable "tags" {
  description = "Tags applied to created nodes."
  type        = map(string)
  default     = {}
}
