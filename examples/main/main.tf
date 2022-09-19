terraform {
  required_version = ">= 1.0"
  experiments      = [module_variable_optional_attrs]

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
    mssql = {
      source  = "betr-io/mssql"
      version = "0.2.5"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "mssql" {
  # Configuration options
}
