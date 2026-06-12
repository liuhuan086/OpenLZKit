resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.name_prefix}${var.workspace_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                       = "${var.name_prefix}${each.key}"
  target_resource_id         = each.value.target_resource_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  dynamic "enabled_log" {
    for_each = toset(each.value.log_category_groups)
    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = each.value.enable_metrics ? ["AllMetrics"] : []
    content {
      category = enabled_metric.value
    }
  }
}
