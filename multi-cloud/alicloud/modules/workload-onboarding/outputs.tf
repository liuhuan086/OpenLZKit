output "resource_group_id" {
  description = "Workload resource group id."
  value       = alicloud_resource_manager_resource_group.this.id
}

output "developer_role_arn" {
  description = "Workload developer role ARN."
  value       = alicloud_ram_role.developer.arn
}

output "tags" {
  description = "Standard FinOps tag set applied to the workload."
  value       = local.tags
}
