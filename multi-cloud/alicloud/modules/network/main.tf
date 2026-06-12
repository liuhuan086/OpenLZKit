resource "alicloud_vpc" "this" {
  vpc_name   = "${var.name_prefix}${var.name}"
  cidr_block = var.cidr_block
  tags       = var.tags
}

resource "alicloud_vswitch" "this" {
  for_each = var.vswitches

  vswitch_name = "${var.name_prefix}${var.name}-${each.key}"
  vpc_id       = alicloud_vpc.this.id
  zone_id      = each.value.zone_id
  cidr_block   = each.value.cidr_block
  tags         = var.tags
}

# Baseline security group: no ingress rules are defined, so inbound is denied by
# default. Workloads add narrowly-scoped rules; public ingress is never the default.
resource "alicloud_security_group" "baseline" {
  security_group_name = "${var.name_prefix}${var.name}-baseline"
  vpc_id              = alicloud_vpc.this.id
  description         = "Default-deny baseline security group for ${var.name}."
  tags                = var.tags
}
