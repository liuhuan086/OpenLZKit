variable "policy_name" {
  description = "Tag policy name."
  type        = string
  default     = "lz-required-tags"
}

variable "required_tag_keys" {
  description = "Tag keys every resource must carry (FinOps governance). See docs/design/11."
  type        = list(string)
  default     = ["owner", "cost_center", "env", "project", "managed_by", "data_classification"]
}

variable "attach_target_id" {
  description = "Optional Resource Directory target to attach the policy to (e.g. RD root or a folder id). Null = create only."
  type        = string
  default     = null
}

variable "attach_target_type" {
  description = "Target type for attachment: Root, Folder, or Account."
  type        = string
  default     = "Root"
}
