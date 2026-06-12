variable "region" {
  description = "AWS region for provider configuration."
  type        = string
  default     = "us-east-1"
}

variable "allowed_regions" {
  description = "Regions allowed by the optional region restriction SCP."
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}

variable "policy_attachments" {
  description = "Organizations policy attachments. Use reviewed root, OU or account ids."
  type = map(object({
    policy_key = string
    target_id  = string
  }))
  default = {}
}
