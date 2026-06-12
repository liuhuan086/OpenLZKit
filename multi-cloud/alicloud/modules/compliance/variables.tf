variable "enable_configuration_recorder" {
  description = "Enable Cloud Config configuration recorder."
  type        = bool
  default     = true
}

variable "recorder_resource_types" {
  description = "Resource types recorded by Cloud Config. Empty lets Alibaba Cloud use the account default."
  type        = set(string)
  default     = []
}

variable "enterprise_edition" {
  description = "Enable Cloud Config enterprise edition where supported."
  type        = bool
  default     = true
}

variable "aggregator_name" {
  description = "Cloud Config aggregator name."
  type        = string
  default     = "lz-compliance"
}

variable "aggregator_description" {
  description = "Cloud Config aggregator description."
  type        = string
  default     = "Landing Zone multi-account compliance aggregator."
}

variable "aggregator_type" {
  description = "Cloud Config aggregator type."
  type        = string
  default     = "RD"
}

variable "folder_id" {
  description = "Optional Resource Directory folder id used by the aggregator."
  type        = string
  default     = null
}

variable "aggregator_accounts" {
  description = "Explicit accounts included by the aggregator when folder-based aggregation is not used."
  type = list(object({
    account_id   = optional(string, null)
    account_name = optional(string, null)
    account_type = optional(string, null)
  }))
  default = []
}

variable "aggregate_rules" {
  description = "Cloud Config aggregate managed rules keyed by stable identifier."
  type = map(object({
    name                        = string
    description                 = optional(string, "")
    source_owner                = string
    source_identifier           = string
    trigger_types               = string
    resource_types_scope        = list(string)
    risk_level                  = number
    input_parameters            = optional(map(string), {})
    maximum_execution_frequency = optional(string, null)
    region_ids_scope            = optional(string, null)
    resource_group_ids_scope    = optional(string, null)
    tag_key_scope               = optional(string, null)
    tag_value_scope             = optional(string, null)
    exclude_resource_ids_scope  = optional(string, null)
    status                      = optional(string, "ACTIVE")
  }))
  default = {}
}

variable "compliance_packs" {
  description = "Aggregate compliance packs keyed by stable identifier."
  type = map(object({
    name                        = string
    description                 = string
    risk_level                  = number
    compliance_pack_template_id = optional(string, null)
    rule_keys                   = optional(list(string), [])
  }))
  default = {}
}

variable "deliveries" {
  description = "Aggregate compliance delivery channels keyed by stable identifier."
  type = map(object({
    name                                   = optional(string, null)
    description                            = optional(string, "")
    delivery_channel_type                  = string
    delivery_channel_target_arn            = string
    oversized_data_oss_target_arn          = optional(string, null)
    delivery_channel_condition             = optional(string, null)
    configuration_item_change_notification = optional(bool, true)
    configuration_snapshot                 = optional(bool, true)
    non_compliant_notification             = optional(bool, true)
    status                                 = optional(number, 1)
  }))
  default = {}
}
