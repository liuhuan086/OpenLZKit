module "connectivity" {
  source = "../../modules/connectivity"

  name_prefix            = "lz-"
  create_transit_gateway = var.create_transit_gateway
  transit_gateway_id     = var.transit_gateway_id
  transit_gateway_arn    = var.transit_gateway_arn
  transit_gateway        = var.transit_gateway
  route_tables           = var.route_tables
  vpc_attachments        = var.vpc_attachments
  routes                 = var.routes
  ram_shares             = var.ram_shares
}
