resource "tencentcloud_ccn" "this" {
  name        = "${var.name_prefix}${var.ccn_name}"
  description = var.description
  tags        = var.tags
}

resource "tencentcloud_ccn_attachment" "this" {
  for_each = var.attachments

  ccn_id          = tencentcloud_ccn.this.id
  instance_type   = "VPC"
  instance_id     = each.value.instance_id
  instance_region = each.value.instance_region
}
