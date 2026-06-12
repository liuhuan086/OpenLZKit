output "vpc_id" {
  description = "VPC id."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block."
  value       = aws_vpc.this.cidr_block
}

output "subnet_ids" {
  description = "Subnet ids by key."
  value       = { for key, subnet in aws_subnet.this : key => subnet.id }
}

output "route_table_ids" {
  description = "Route table ids by key."
  value       = { for key, route_table in aws_route_table.this : key => route_table.id }
}

output "nat_gateway_ids" {
  description = "NAT gateway ids by key."
  value       = { for key, nat in aws_nat_gateway.this : key => nat.id }
}

output "security_group_ids" {
  description = "Security group ids by key."
  value       = { for key, security_group in aws_security_group.this : key => security_group.id }
}

output "vpc_endpoint_ids" {
  description = "VPC endpoint ids by key."
  value       = { for key, endpoint in aws_vpc_endpoint.this : key => endpoint.id }
}
