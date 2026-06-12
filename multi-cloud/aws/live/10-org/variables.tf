variable "region" {
  description = "AWS region for Organizations API calls."
  type        = string
  default     = "us-east-1"
}

variable "account_common_tags" {
  description = "Tags merged onto every vended account."
  type        = map(string)
  default = {
    managed_by = "terraform"
    project    = "openlzkit"
  }
}

variable "accounts" {
  description = "Accounts to vend. Keep empty until a reviewed account request is approved."
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
