output "state_resource_group" {
  description = "Resource group holding the state storage account."
  value       = azurerm_resource_group.platform.name
}

output "state_storage_account" {
  description = "Storage account for remote Terraform state."
  value       = azurerm_storage_account.state.name
}

output "tfstate_container" {
  description = "Blob container for state files."
  value       = azurerm_storage_container.tfstate.name
}

output "ci_client_id" {
  description = "Client id of the GitHub Actions OIDC application."
  value       = azuread_application.ci.client_id
}
