output "vpc_id" {
  description = "Created VPC id."
  value       = alicloud_vpc.this.id
}

output "vswitch_ids" {
  description = "Map of vswitch key to vswitch id."
  value       = { for k, v in alicloud_vswitch.this : k => v.id }
}

output "baseline_security_group_id" {
  description = "Default-deny baseline security group id."
  value       = alicloud_security_group.baseline.id
}
