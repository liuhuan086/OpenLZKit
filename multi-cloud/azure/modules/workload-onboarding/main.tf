locals {
  name = "${var.name_prefix}${var.workload_name}-${var.env}"

  # Standard FinOps tag set (matches the finops require-tag policy).
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
resource "azurerm_resource_group" "this" {
  name     = local.name
  location = var.location
  tags     = local.tags
}

# Workload-scoped managed identity for the application.
resource "azurerm_user_assigned_identity" "workload" {
  name                = "${local.name}-id"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  tags                = local.tags
}

# Workload team access, scoped to the workload resource group only.
resource "azurerm_role_assignment" "team" {
  count = var.admin_principal_id == null ? 0 : 1

  scope                = azurerm_resource_group.this.id
  role_definition_name = var.admin_role
  principal_id         = var.admin_principal_id
  principal_type       = "Group"
}
