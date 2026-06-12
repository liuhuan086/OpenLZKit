output "vpc_id" {
  description = "VPC id."
  value       = module.network.vpc_id
}

output "subnet_ids" {
  description = "Subnet ids by key."
  value       = module.network.subnet_ids
}

output "route_table_ids" {
  description = "Route table ids by key."
  value       = module.network.route_table_ids
}
