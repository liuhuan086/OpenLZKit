variable "region" {
  description = "AWS region for compliance resources."
  type        = string
  default     = "us-east-1"
}

variable "enable_security_hub" {
  description = "Enable Security Hub in the current account."
  type        = bool
  default     = false
}

variable "security_hub_admin_account_id" {
  description = "Organization delegated admin account id for Security Hub."
  type        = string
  default     = null
}

variable "security_hub_standards" {
  description = "Security Hub standards subscriptions keyed by stable identifier."
  type = map(object({
    standards_arn = string
  }))
  default = {}
}

variable "enable_guardduty_detector" {
  description = "Enable GuardDuty detector in the current account."
  type        = bool
  default     = false
}

variable "guardduty_admin_account_id" {
  description = "Organization delegated admin account id for GuardDuty."
  type        = string
  default     = null
}

variable "config_aggregators" {
  description = "AWS Config organization aggregators keyed by stable identifier."
  type = map(object({
    name        = string
    role_arn    = string
    all_regions = optional(bool, true)
    regions     = optional(list(string), [])
    tags        = optional(map(string), {})
  }))
  default = {}
}

variable "config_managed_rules" {
  description = "AWS Config managed rules keyed by stable identifier."
  type = map(object({
    name                        = string
    source_identifier           = string
    description                 = optional(string, "")
    input_parameters            = optional(map(string), {})
    maximum_execution_frequency = optional(string, "TwentyFour_Hours")
    tags                        = optional(map(string), {})
  }))
  default = {}
}

variable "conformance_packs" {
  description = "AWS Config conformance packs keyed by stable identifier."
  type = map(object({
    name                   = string
    template_body          = string
    delivery_s3_bucket     = optional(string, null)
    delivery_s3_key_prefix = optional(string, null)
  }))
  default = {}
}
