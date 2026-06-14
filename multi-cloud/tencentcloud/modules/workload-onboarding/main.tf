locals {
  name = "${var.name_prefix}${var.workload_name}-${var.env}"

  # Standard FinOps tag set (mirrors the other clouds' tag set).
  tags = merge({
    owner               = var.owner
    cost_center         = var.cost_center
    env                 = var.env
    project             = var.workload_name
    managed_by          = "terraform"
    data_classification = var.data_classification
  }, var.extra_tags)
}

# Workload CAM role, assumed from the management account (no long-lived SecretKey).
resource "tencentcloud_cam_role" "workload" {
  name        = "${local.name}-role"
  description = "Workload role for ${var.workload_name} (${var.env})."
  tags        = local.tags

  document = jsonencode({
    version = "2.0"
    statement = [{
      effect    = "allow"
      action    = ["name/sts:AssumeRole"]
      principal = { qcs = ["qcs::cam::uin/${var.management_uin}:root"] }
    }]
  })
}

resource "tencentcloud_cam_role_policy_attachment" "team" {
  for_each = toset([for id in var.team_policy_ids : tostring(id)])

  role_id   = tencentcloud_cam_role.workload.id
  policy_id = tonumber(each.value)
}
