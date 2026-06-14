resource "tencentcloud_vpc" "this" {
  name       = "${var.name_prefix}${var.name}"
  cidr_block = var.cidr_block
  tags       = var.tags
}

resource "tencentcloud_subnet" "this" {
  for_each = var.subnets

  name              = "${var.name_prefix}${var.name}-${each.key}"
  vpc_id            = tencentcloud_vpc.this.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr_block
  tags              = var.tags
}

# Baseline security group: no rules defined, so inbound is denied by default.
# Workloads add narrowly-scoped rules; public ingress is never the default.
resource "tencentcloud_security_group" "baseline" {
  name        = "${var.name_prefix}${var.name}-baseline"
  description = "Default-deny baseline security group for ${var.name}."
  tags        = var.tags
}
