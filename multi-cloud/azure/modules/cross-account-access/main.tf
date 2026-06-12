locals {
  # Flatten "<identity_key>/<cred_key>" federated credentials.
  federated_credentials = merge(concat([{}], [
    for mi_key, mi in var.managed_identities : {
      for fc_key, fc in mi.federated_credentials :
      "${mi_key}/${fc_key}" => merge(fc, { mi_key = mi_key })
    }
  ])...)
}

resource "azurerm_user_assigned_identity" "this" {
  for_each = var.managed_identities

  name                = "${var.name_prefix}${each.key}"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
}

resource "azurerm_federated_identity_credential" "this" {
  for_each = local.federated_credentials

  name                = replace(each.key, "/", "-")
  resource_group_name = var.managed_identities[each.value.mi_key].resource_group_name
  parent_id           = azurerm_user_assigned_identity.this[each.value.mi_key].id
  audience            = each.value.audience
  issuer              = each.value.issuer
  subject             = each.value.subject
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_type       = each.value.principal_type
  description          = each.value.description
  condition            = each.value.condition
  condition_version    = each.value.condition_version

  principal_id = each.value.managed_identity_key == null ? each.value.principal_id : azurerm_user_assigned_identity.this[each.value.managed_identity_key].principal_id
}
