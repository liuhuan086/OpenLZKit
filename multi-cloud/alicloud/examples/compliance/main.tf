variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

provider "alicloud" {
  region = var.region
}

module "compliance" {
  source = "../../modules/compliance"

  aggregator_name        = "lz-compliance"
  aggregator_description = "Landing Zone aggregate compliance checks."
  aggregator_type        = "RD"
  folder_id              = "fd-example-workloads"

  recorder_resource_types = [
    "ACS::ECS::Instance",
    "ACS::OSS::Bucket",
    "ACS::VPC::SecurityGroup",
  ]

  aggregate_rules = {
    required_tags = {
      name                 = "required-tags"
      description          = "Resources must carry Landing Zone FinOps tags."
      source_owner         = "ALIYUN"
      source_identifier    = "required-tags"
      trigger_types        = "ConfigurationItemChangeNotification"
      resource_types_scope = ["ACS::ECS::Instance", "ACS::OSS::Bucket"]
      risk_level           = 2
      input_parameters = {
        tagKey = "owner,cost_center,env,project,managed_by,data_classification"
      }
    }
    public_security_group = {
      name                 = "no-public-sg-high-risk"
      description          = "Security groups must not expose high-risk ports to the Internet."
      source_owner         = "ALIYUN"
      source_identifier    = "sg-public-check"
      trigger_types        = "ConfigurationItemChangeNotification"
      resource_types_scope = ["ACS::VPC::SecurityGroup"]
      risk_level           = 1
    }
  }

  compliance_packs = {
    landing_zone_baseline = {
      name        = "landing-zone-baseline"
      description = "Landing Zone baseline compliance pack."
      risk_level  = 2
      rule_keys   = ["required_tags", "public_security_group"]
    }
  }

  deliveries = {
    audit_sls = {
      name                        = "audit-sls"
      delivery_channel_type       = "SLS"
      delivery_channel_target_arn = "acs:log:cn-hangzhou:1234567890123456:project/lz-audit/logstore/actiontrail"
    }
  }
}

output "aggregator_id" {
  description = "Cloud Config aggregator id."
  value       = module.compliance.aggregator_id
}

output "aggregate_rule_ids" {
  description = "Aggregate rule ids by key."
  value       = module.compliance.aggregate_rule_ids
}
