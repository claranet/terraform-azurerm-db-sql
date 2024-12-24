terraform {
  required_version = ">= 1.8"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    mssql = {
      source  = "betr-io/mssql"
      version = ">= 0.2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "mssql" {
  # Configuration options
}
