terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0"
    }
  }

  # Bootstrap runs with LOCAL state: it creates the storage account that later
  # stacks use as their azurerm backend. After apply, migrate this state in.
}
