terraform {
  required_version = ">= 0.14"
  experiments      = [module_variable_optional_attrs]

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.31"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
    mssql = {
      source  = "betr-io/mssql"
      version = "0.2.3"
    }
  }
}

provider "azurerm" {
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id

  features {}
}

provider "mssql" {
  # Configuration options
}
