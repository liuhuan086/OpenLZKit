output "transit_gateway_id" {
  description = "Transit Gateway id."
  value       = module.connectivity.transit_gateway_id
}

output "route_table_ids" {
  description = "Transit Gateway route table ids by key."
  value       = module.connectivity.route_table_ids
}

output "vpc_attachment_ids" {
  description = "Transit Gateway VPC attachment ids by key."
  value       = module.connectivity.vpc_attachment_ids
}
