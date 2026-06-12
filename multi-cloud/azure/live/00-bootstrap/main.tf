provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {}

resource "azurerm_resource_group" "platform" {
  name     = var.state_resource_group_name
  location = var.location
  tags     = var.tags
}

# --- Remote state storage --------------------------------------------------
resource "azurerm_storage_account" "state" {
  name                = var.state_storage_account_name
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  account_tier             = "Standard"
  account_replication_type = "GRS"

  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  allow_nested_items_to_be_public   = false
  shared_access_key_enabled         = false
  default_to_oauth_authentication   = true
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = true

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.tfstate_container_name
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"
}

# --- GitHub Actions OIDC federation ---------------------------------------
resource "azuread_application" "ci" {
  display_name = "${var.name_prefix}github-actions"
}

resource "azuread_service_principal" "ci" {
  client_id = azuread_application.ci.client_id
}

resource "azuread_application_federated_identity_credential" "ci" {
  application_id = azuread_application.ci.id
  display_name   = "github-actions-main"
  issuer         = "https://token.actions.githubusercontent.com"
  audiences      = ["api://AzureADTokenExchange"]
  subject        = "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/main"
}

# Plan-only CI role; scope it to a subscription/management group via ci_role_scope.
resource "azurerm_role_assignment" "ci" {
  count = var.ci_role_scope == null ? 0 : 1

  scope                = var.ci_role_scope
  role_definition_name = var.ci_role_definition_name
  principal_id         = azuread_service_principal.ci.object_id
}
