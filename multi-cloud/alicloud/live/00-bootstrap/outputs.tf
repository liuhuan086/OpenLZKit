output "state_bucket" {
  description = "OSS bucket holding remote Terraform state for later stacks."
  value       = alicloud_oss_bucket.state.bucket
}

output "resource_directory_id" {
  description = "Resource Directory id (empty if enabling was skipped)."
  value       = try(alicloud_resource_manager_resource_directory.this[0].id, null)
}

output "cicd_plan_role_arn" {
  description = "ARN of the GitHub Actions plan/validate role."
  value       = alicloud_ram_role.cicd_plan.arn
}
