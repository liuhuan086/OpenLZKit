locals {
  transit_gateway_id  = var.create_transit_gateway ? aws_ec2_transit_gateway.this[0].id : var.transit_gateway_id
  transit_gateway_arn = var.create_transit_gateway ? aws_ec2_transit_gateway.this[0].arn : var.transit_gateway_arn

  route_table_tags = {
    for key, route_table in var.route_tables :
    key => merge(var.common_tags, route_table.tags, {
      Name         = "${var.name_prefix}${route_table.name}"
      network_zone = key
    })
  }

  attachment_tags = {
    for key, attachment in var.vpc_attachments :
    key => merge(var.common_tags, attachment.tags, {
      Name       = "${var.name_prefix}${attachment.name}"
      attachment = key
    })
  }

  share_tags = {
    for key, share in var.ram_shares :
    key => merge(var.common_tags, share.tags, {
      Name = "${var.name_prefix}${share.name}"
    })
  }

  propagations = merge(concat([{}], [
    for attachment_key, attachment in var.vpc_attachments : {
      for route_table_key in attachment.propagate_to_keys :
      "${attachment_key}:${route_table_key}" => {
        attachment      = attachment_key
        route_table_key = route_table_key
      }
    }
  ])...)

  ram_principal_associations = merge(concat([{}], [
    for share_key, share in var.ram_shares : {
      for principal in share.principals :
      "${share_key}:${principal}" => {
        share     = share_key
        principal = principal
      }
    }
  ])...)

  ram_resource_arns = {
    for share_key, share in var.ram_shares :
    share_key => distinct(concat(
      share.resource_arns,
      share.share_transit_gateway && local.transit_gateway_arn != null ? [local.transit_gateway_arn] : []
    ))
  }

  ram_resource_associations = merge(concat([{}], [
    for share_key, resource_arns in local.ram_resource_arns : {
      for resource_arn in resource_arns :
      "${share_key}:${resource_arn}" => {
        share        = share_key
        resource_arn = resource_arn
      }
    }
  ])...)
}

resource "aws_ec2_transit_gateway" "this" {
  #checkov:skip=CKV_AWS_331:Checkov 3.3.0 raises TypeError on TGW variable-backed option maps.
  count = var.create_transit_gateway ? 1 : 0

  description                        = var.transit_gateway.description
  amazon_side_asn                    = var.transit_gateway.amazon_side_asn
  auto_accept_shared_attachments     = var.transit_gateway.auto_accept_shared_attachments
  default_route_table_association    = var.transit_gateway.default_route_table_association
  default_route_table_propagation    = var.transit_gateway.default_route_table_propagation
  dns_support                        = var.transit_gateway.dns_support
  multicast_support                  = var.transit_gateway.multicast_support
  security_group_referencing_support = var.transit_gateway.security_group_referencing_support
  transit_gateway_cidr_blocks        = var.transit_gateway.transit_gateway_cidr_blocks
  vpn_ecmp_support                   = var.transit_gateway.vpn_ecmp_support
  tags                               = merge(var.common_tags, var.transit_gateway.tags, { Name = "${var.name_prefix}${var.transit_gateway.name}" })
}

resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each = var.route_tables

  transit_gateway_id = local.transit_gateway_id
  tags               = local.route_table_tags[each.key]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = var.vpc_attachments

  transit_gateway_id                              = local.transit_gateway_id
  vpc_id                                          = each.value.vpc_id
  subnet_ids                                      = each.value.subnet_ids
  appliance_mode_support                          = each.value.appliance_mode_support
  dns_support                                     = each.value.dns_support
  ipv6_support                                    = each.value.ipv6_support
  security_group_referencing_support              = each.value.security_group_referencing_support
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags                                            = local.attachment_tags[each.key]
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = var.vpc_attachments

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = local.propagations

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id
}

resource "aws_ec2_transit_gateway_route" "this" {
  for_each = var.routes

  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id
  transit_gateway_attachment_id  = each.value.blackhole ? null : try(aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment_key].id, null)
  blackhole                      = each.value.blackhole

  lifecycle {
    precondition {
      condition     = each.value.blackhole || contains(keys(var.vpc_attachments), each.value.attachment_key)
      error_message = "Each non-blackhole route attachment_key must exist in var.vpc_attachments."
    }
  }
}

resource "aws_ram_resource_share" "this" {
  for_each = var.ram_shares

  name                      = "${var.name_prefix}${each.value.name}"
  allow_external_principals = each.value.allow_external_principals
  permission_arns           = each.value.permission_arns
  tags                      = local.share_tags[each.key]
}

resource "aws_ram_principal_association" "this" {
  for_each = local.ram_principal_associations

  resource_share_arn = aws_ram_resource_share.this[each.value.share].arn
  principal          = each.value.principal
}

resource "aws_ram_resource_association" "this" {
  for_each = local.ram_resource_associations

  resource_share_arn = aws_ram_resource_share.this[each.value.share].arn
  resource_arn       = each.value.resource_arn
}
