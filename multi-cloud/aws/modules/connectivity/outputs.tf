output "transit_gateway_id" {
  description = "Transit Gateway id."
  value       = local.transit_gateway_id
}

output "transit_gateway_arn" {
  description = "Transit Gateway ARN."
  value       = local.transit_gateway_arn
}

output "route_table_ids" {
  description = "Transit Gateway route table ids by key."
  value       = { for key, route_table in aws_ec2_transit_gateway_route_table.this : key => route_table.id }
}

output "vpc_attachment_ids" {
  description = "Transit Gateway VPC attachment ids by key."
  value       = { for key, attachment in aws_ec2_transit_gateway_vpc_attachment.this : key => attachment.id }
}

output "ram_resource_share_arns" {
  description = "AWS RAM resource share ARNs by key."
  value       = { for key, share in aws_ram_resource_share.this : key => share.arn }
}
