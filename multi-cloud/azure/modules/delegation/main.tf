# Azure built-in Owner role id — delegations must never grant it.
locals {
  owner_role_id = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"

  invalid_owner_grants = [
    for dk, d in var.delegations : dk
    if length([for a in d.authorizations : a if endswith(a.role_definition_id, local.owner_role_id)]) > 0
  ]
}

resource "azurerm_lighthouse_definition" "this" {
  for_each = var.delegations

  name               = "${var.name_prefix}${each.value.name}"
  description        = each.value.description
  managing_tenant_id = each.value.managing_tenant_id
  scope              = each.value.scope

  dynamic "authorization" {
    for_each = each.value.authorizations
    content {
      principal_id                  = authorization.value.principal_id
      role_definition_id            = authorization.value.role_definition_id
      principal_display_name        = authorization.value.principal_display_name
      delegated_role_definition_ids = authorization.value.delegated_role_definition_ids
    }
  }

  lifecycle {
    precondition {
      condition     = length(local.invalid_owner_grants) == 0
      error_message = "Lighthouse delegations must not grant the Owner role: ${join(", ", local.invalid_owner_grants)}."
    }
  }
}

resource "azurerm_lighthouse_assignment" "this" {
  for_each = var.delegations

  lighthouse_definition_id = azurerm_lighthouse_definition.this[each.key].id
  scope                    = each.value.scope
}
