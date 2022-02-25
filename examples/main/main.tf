terraform {
  required_version = ">= 0.14"
  experiments      = [module_variable_optional_attrs]

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.97"
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
  features {}
}

provider "mssql" {
  # Configuration options
}
