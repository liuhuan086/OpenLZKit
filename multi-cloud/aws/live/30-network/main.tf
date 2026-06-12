module "network" {
  source = "../../modules/network"

  name_prefix             = var.name_prefix
  vpc                     = var.vpc
  subnets                 = var.subnets
  route_tables            = var.route_tables
  create_internet_gateway = var.create_internet_gateway
  nat_gateways            = var.nat_gateways
  vpc_endpoints           = var.vpc_endpoints
  security_groups         = var.security_groups
  flow_logs               = var.flow_logs
}
