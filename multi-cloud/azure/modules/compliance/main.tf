resource "azurerm_security_center_subscription_pricing" "this" {
  for_each = var.defender_plans

  resource_type = each.key
  tier          = each.value.tier
  subplan       = each.value.subplan
}

resource "azurerm_security_center_contact" "this" {
  count = var.security_contact == null ? 0 : 1

  name                = var.security_contact.name
  email               = var.security_contact.email
  phone               = var.security_contact.phone
  alert_notifications = var.security_contact.alert_notifications
  alerts_to_admins    = var.security_contact.alerts_to_admins
}
