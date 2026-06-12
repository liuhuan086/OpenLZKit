output "cen_id" {
  description = "CEN instance id."
  value       = local.cen_id
}

output "transit_router_id" {
  description = "Transit Router id."
  value       = alicloud_cen_transit_router.this.transit_router_id
}

output "route_table_ids" {
  description = "Transit Router route table ids by key."
  value       = { for k, table in alicloud_cen_transit_router_route_table.this : k => table.transit_router_route_table_id }
}

output "vpc_attachment_ids" {
  description = "Transit Router VPC attachment ids by key."
  value       = { for k, attachment in alicloud_cen_transit_router_vpc_attachment.this : k => attachment.transit_router_attachment_id }
}

output "grant_attachment_ids" {
  description = "Transit Router grant attachment ids by key."
  value       = { for k, grant in alicloud_cen_transit_router_grant_attachment.this : k => grant.id }
}
