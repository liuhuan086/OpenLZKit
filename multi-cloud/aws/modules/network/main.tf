locals {
  vpc_tags = merge(var.common_tags, var.vpc.tags, { Name = "${var.name_prefix}${var.vpc.name}" })

  subnet_tags = {
    for key, subnet in var.subnets :
    key => merge(var.common_tags, subnet.tags, { Name = "${var.name_prefix}${subnet.name}" })
  }

  route_table_tags = {
    for key, route_table in var.route_tables :
    key => merge(var.common_tags, route_table.tags, { Name = "${var.name_prefix}${route_table.name}" })
  }

  nat_tags = {
    for key, nat in var.nat_gateways :
    key => merge(var.common_tags, nat.tags, { Name = "${var.name_prefix}${nat.name}" })
  }

  endpoint_tags = {
    for key, endpoint in var.vpc_endpoints :
    key => merge(var.common_tags, endpoint.tags, { Name = "${var.name_prefix}${key}" })
  }

  security_group_tags = {
    for key, security_group in var.security_groups :
    key => merge(var.common_tags, security_group.tags, { Name = "${var.name_prefix}${security_group.name}" })
  }

  flow_log_tags = {
    for key, flow_log in var.flow_logs :
    key => merge(var.common_tags, flow_log.tags, { Name = "${var.name_prefix}${key}" })
  }
}

resource "aws_vpc" "this" {
  cidr_block                       = var.vpc.cidr_block
  assign_generated_ipv6_cidr_block = var.vpc.assign_generated_ipv6_cidr_block
  enable_dns_hostnames             = var.vpc.enable_dns_hostnames
  enable_dns_support               = var.vpc.enable_dns_support
  instance_tenancy                 = var.vpc.instance_tenancy
  tags                             = local.vpc_tags
}

resource "aws_internet_gateway" "this" {
  count = var.create_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.this.id
  tags   = merge(var.common_tags, { Name = "${var.name_prefix}${var.vpc.name}-igw" })
}

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  availability_zone_id    = each.value.availability_zone_id
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  tags                    = local.subnet_tags[each.key]
}

resource "aws_eip" "nat" {
  for_each = {
    for key, nat in var.nat_gateways : key => nat
    if nat.connectivity_type == "public"
  }

  domain = "vpc"
  tags   = merge(local.nat_tags[each.key], { Name = "${var.name_prefix}${each.value.name}-eip" })
}

resource "aws_nat_gateway" "this" {
  for_each = var.nat_gateways

  subnet_id         = aws_subnet.this[each.value.public_subnet_key].id
  connectivity_type = each.value.connectivity_type
  allocation_id     = each.value.connectivity_type == "public" ? aws_eip.nat[each.key].id : null
  tags              = local.nat_tags[each.key]
}

resource "aws_route_table" "this" {
  for_each = var.route_tables

  vpc_id = aws_vpc.this.id
  tags   = local.route_table_tags[each.key]

  dynamic "route" {
    for_each = each.value.routes
    content {
      cidr_block             = route.value.cidr_block
      ipv6_cidr_block        = route.value.ipv6_cidr_block
      gateway_id             = route.value.gateway_key == "internet_gateway" && var.create_internet_gateway ? aws_internet_gateway.this[0].id : null
      nat_gateway_id         = route.value.nat_gateway_key == null ? null : aws_nat_gateway.this[route.value.nat_gateway_key].id
      transit_gateway_id     = route.value.transit_gateway_id
      egress_only_gateway_id = route.value.egress_only_gateway_id
      network_interface_id   = route.value.network_interface_id
    }
  }
}

resource "aws_route_table_association" "subnet" {
  for_each = var.subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this[each.value.route_table_key].id

  lifecycle {
    precondition {
      condition     = contains(keys(var.route_tables), each.value.route_table_key)
      error_message = "Each subnet route_table_key must exist in var.route_tables."
    }
  }
}

resource "aws_security_group" "this" {
  for_each = var.security_groups

  name        = "${var.name_prefix}${each.value.name}"
  description = each.value.description
  vpc_id      = aws_vpc.this.id
  tags        = local.security_group_tags[each.key]

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
      security_groups  = ingress.value.security_groups
      self             = ingress.value.self
    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
      security_groups  = egress.value.security_groups
      self             = egress.value.self
    }
  }
}

resource "aws_vpc_endpoint" "this" {
  for_each = var.vpc_endpoints

  vpc_id              = aws_vpc.this.id
  service_name        = each.value.service_name
  vpc_endpoint_type   = each.value.vpc_endpoint_type
  subnet_ids          = [for subnet_key in each.value.subnet_keys : aws_subnet.this[subnet_key].id]
  route_table_ids     = [for route_table_key in each.value.route_table_keys : aws_route_table.this[route_table_key].id]
  security_group_ids  = [for security_group_key in each.value.security_group_keys : aws_security_group.this[security_group_key].id]
  private_dns_enabled = each.value.private_dns_enabled
  policy              = each.value.policy
  tags                = local.endpoint_tags[each.key]
}

resource "aws_flow_log" "this" {
  for_each = var.flow_logs

  vpc_id               = aws_vpc.this.id
  log_destination      = each.value.log_destination
  log_destination_type = each.value.log_destination_type
  traffic_type         = each.value.traffic_type
  iam_role_arn         = each.value.iam_role_arn
  log_format           = each.value.log_format
  tags                 = local.flow_log_tags[each.key]
}
