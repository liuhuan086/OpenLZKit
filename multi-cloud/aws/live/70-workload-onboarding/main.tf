module "workload_onboarding" {
  source = "../../modules/workload-onboarding"

  name_prefix                = var.name_prefix
  parameter_prefix           = var.parameter_prefix
  create_metadata_parameters = var.create_metadata_parameters
  max_session_duration       = var.max_session_duration
  workloads                  = var.workloads
  common_tags                = var.common_tags
}
