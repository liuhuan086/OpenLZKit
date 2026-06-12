variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

variable "folder_id" {
  description = "Optional Resource Directory folder id used by the aggregator."
  type        = string
  default     = null
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

provider "alicloud" {
  region = var.region
}

module "compliance" {
  source = "../../modules/compliance"

  folder_id        = var.folder_id
  aggregate_rules  = var.aggregate_rules
  compliance_packs = var.compliance_packs
  deliveries       = var.deliveries
}

output "aggregator_id" {
  description = "Cloud Config aggregator id."
  value       = module.compliance.aggregator_id
}

output "aggregate_rule_ids" {
  description = "Aggregate rule ids by key."
  value       = module.compliance.aggregate_rule_ids
}
