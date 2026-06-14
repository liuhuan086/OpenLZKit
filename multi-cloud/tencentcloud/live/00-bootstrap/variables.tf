variable "region" {
  description = "Tencent Cloud region for the COS state bucket."
  type        = string
  default     = "ap-guangzhou"
}

variable "name_prefix" {
  description = "Prefix applied to created CAM resource names."
  type        = string
  default     = "lz-"
}

variable "state_bucket_name" {
  description = "COS bucket name for remote Terraform state (must include the APPID suffix, e.g. lz-tfstate-1250000000)."
  type        = string
}

variable "management_uin" {
  description = "Root UIN of the management account allowed to assume the CI role via STS."
  type        = string
}

variable "tags" {
  description = "Tags applied to the COS bucket."
  type        = map(string)
  default     = {}
}
