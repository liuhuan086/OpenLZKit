output "role_id" {
  description = "Workload CAM role id."
  value       = tencentcloud_cam_role.workload.id
}

output "tags" {
  description = "Standard FinOps tag set applied to the workload."
  value       = local.tags
}
