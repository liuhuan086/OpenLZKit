output "workload_tags" {
  description = "Standardized workload tags by key."
  value       = local.workload_tags
}

output "role_arns" {
  description = "Workload access role ARNs by workload key."
  value       = { for key, role in aws_iam_role.workload : key => role.arn }
}

output "metadata_parameter_names" {
  description = "SSM metadata parameter names by workload metadata key."
  value       = { for key, parameter in aws_ssm_parameter.metadata : key => parameter.name }
}
