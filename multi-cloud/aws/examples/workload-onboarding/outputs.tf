output "workload_tags" {
  description = "Standard workload tags by key."
  value       = module.workload_onboarding.workload_tags
}

output "role_arns" {
  description = "Workload access role ARNs by workload key."
  value       = module.workload_onboarding.role_arns
}

output "metadata_parameter_names" {
  description = "SSM metadata parameter names by key."
  value       = module.workload_onboarding.metadata_parameter_names
}
