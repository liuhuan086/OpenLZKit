locals {
  cen_id = var.create_cen ? alicloud_cen_instance.this[0].id : var.existing_cen_id

  route_table_tags = {
    for key, table in var.route_tables :
    key => merge(var.common_tags, table.tags)
  }

  attachment_tags = {
    for key, attachment in var.vpc_attachments :
    key => merge(var.common_tags, attachment.tags)
  }

  associations = {
    for key, attachment in var.vpc_attachments :
    key => attachment
    if attachment.route_table_association_key != null
  }

  propagations = {
    for key, attachment in var.vpc_attachments :
    key => attachment
    if attachment.route_table_propagation_key != null
  }

  route_next_hop_ids = {
    for key, route in var.route_entries :
    key => (
      route.attachment_key != null ?
      alicloud_cen_transit_router_vpc_attachment.this[route.attachment_key].transit_router_attachment_id :
      route.next_hop_id
    )
  }
}

resource "alicloud_cen_instance" "this" {
  count = var.create_cen ? 1 : 0

  cen_instance_name = "${var.name_prefix}${var.cen_name}"
  description       = var.cen_description
  tags              = var.common_tags
}

resource "alicloud_cen_transit_router" "this" {
  cen_id                     = local.cen_id
  transit_router_name        = "${var.name_prefix}${var.transit_router_name}"
  transit_router_description = "Transit Router for ${var.cen_name}."
  support_multicast          = var.support_multicast
  tags                       = var.common_tags
}

resource "alicloud_cen_transit_router_route_table" "this" {
  for_each = var.route_tables

  transit_router_id                      = alicloud_cen_transit_router.this.transit_router_id
  transit_router_route_table_name        = "${var.name_prefix}${each.value.name}"
  transit_router_route_table_description = each.value.description
  tags                                   = local.route_table_tags[each.key]
}

resource "alicloud_cen_transit_router_vpc_attachment" "this" {
  for_each = var.vpc_attachments

  cen_id                               = local.cen_id
  transit_router_id                    = alicloud_cen_transit_router.this.transit_router_id
  transit_router_vpc_attachment_name   = "${var.name_prefix}${each.value.name}"
  transit_router_attachment_description = "VPC attachment ${each.value.name}."
  vpc_id                               = each.value.vpc_id
  vpc_owner_id                         = each.value.vpc_owner_id
  auto_publish_route_enabled           = each.value.auto_publish_route_enabled
  force_delete                         = each.value.force_delete
  tags                                 = local.attachment_tags[each.key]

  dynamic "zone_mappings" {
    for_each = each.value.zone_mappings
    content {
      zone_id    = zone_mappings.value.zone_id
      vswitch_id = zone_mappings.value.vswitch_id
    }
  }
}

resource "alicloud_cen_transit_router_grant_attachment" "this" {
  for_each = var.grant_attachments

  cen_id        = local.cen_id
  cen_owner_id  = each.value.cen_owner_id
  instance_id   = each.value.instance_id
  instance_type = each.value.instance_type
}

resource "alicloud_cen_transit_router_route_table_association" "this" {
  for_each = local.associations

  transit_router_attachment_id  = alicloud_cen_transit_router_vpc_attachment.this[each.key].transit_router_attachment_id
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.this[each.value.route_table_association_key].transit_router_route_table_id

  lifecycle {
    precondition {
      condition     = contains(keys(var.route_tables), each.value.route_table_association_key)
      error_message = "Each route_table_association_key must exist in var.route_tables."
    }
  }
}

resource "alicloud_cen_transit_router_route_table_propagation" "this" {
  for_each = local.propagations

  transit_router_attachment_id  = alicloud_cen_transit_router_vpc_attachment.this[each.key].transit_router_attachment_id
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.this[each.value.route_table_propagation_key].transit_router_route_table_id

  lifecycle {
    precondition {
      condition     = contains(keys(var.route_tables), each.value.route_table_propagation_key)
      error_message = "Each route_table_propagation_key must exist in var.route_tables."
    }
  }
}

resource "alicloud_cen_transit_router_route_entry" "this" {
  for_each = var.route_entries

  transit_router_route_table_id                     = alicloud_cen_transit_router_route_table.this[each.value.route_table_key].transit_router_route_table_id
  transit_router_route_entry_destination_cidr_block = each.value.destination_cidr
  transit_router_route_entry_next_hop_type          = each.value.next_hop_type
  transit_router_route_entry_next_hop_id            = local.route_next_hop_ids[each.key]
  transit_router_route_entry_name                   = each.value.name
  transit_router_route_entry_description            = each.value.description

  lifecycle {
    precondition {
      condition     = contains(keys(var.route_tables), each.value.route_table_key)
      error_message = "Each route_entry route_table_key must exist in var.route_tables."
    }

    precondition {
      condition     = each.value.attachment_key == null || contains(keys(var.vpc_attachments), each.value.attachment_key)
      error_message = "Each route_entry attachment_key must exist in var.vpc_attachments."
    }
  }
}
