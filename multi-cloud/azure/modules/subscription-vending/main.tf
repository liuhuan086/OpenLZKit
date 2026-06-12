# Create new subscriptions under a billing scope (off by default — billing impact).
resource "azurerm_subscription" "this" {
  for_each = var.subscriptions

  alias             = each.key
  subscription_name = each.value.subscription_name
  billing_scope_id  = each.value.billing_scope_id
  workload          = each.value.workload
  tags              = merge(var.common_tags, each.value.tags)
}

# Place existing subscriptions into the management group hierarchy.
resource "azurerm_management_group_subscription_association" "this" {
  for_each = var.associations

  management_group_id = each.value.management_group_id
  subscription_id     = each.value.subscription_id
}
