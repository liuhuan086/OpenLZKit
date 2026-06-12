locals {
  name = "${var.name_prefix}${var.workload_name}-${var.env}"

  # Standard FinOps tag set (matches modules/finops required keys).
  tags = merge({
    owner               = var.owner
    cost_center         = var.cost_center
    env                 = var.env
    project             = var.workload_name
    managed_by          = "terraform"
    data_classification = var.data_classification
  }, var.extra_tags)
}

# Isolated resource group for the workload's resources.
resource "alicloud_resource_manager_resource_group" "this" {
  resource_group_name = local.name
  display_name        = "${var.workload_name} ${var.env}"
  tags                = local.tags
}

# Workload-scoped developer role, assumable by the app team.
resource "alicloud_ram_role" "developer" {
  role_name   = "${local.name}-developer"
  description = "Developer role for workload ${var.workload_name} (${var.env})."

  assume_role_policy_document = jsonencode({
    Version = "1"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { RAM = var.trusted_principals }
    }]
  })
}
