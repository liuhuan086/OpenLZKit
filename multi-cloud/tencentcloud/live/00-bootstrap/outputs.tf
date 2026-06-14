output "state_bucket" {
  description = "COS bucket for remote Terraform state."
  value       = tencentcloud_cos_bucket.state.bucket
}

output "cicd_role_name" {
  description = "Name of the CI/CD plan role."
  value       = tencentcloud_cam_role.cicd_plan.name
}
