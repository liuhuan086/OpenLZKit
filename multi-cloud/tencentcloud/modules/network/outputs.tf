output "vpc_id" {
  description = "Created VPC id."
  value       = tencentcloud_vpc.this.id
}

output "subnet_ids" {
  description = "Map of subnet name to subnet id."
  value       = { for k, s in tencentcloud_subnet.this : k => s.id }
}

output "baseline_security_group_id" {
  description = "Default-deny baseline security group id."
  value       = tencentcloud_security_group.baseline.id
}
