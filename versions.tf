terraform {
  required_version = ">= 1.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.39"
    }
    # tflint-ignore: terraform_unused_required_providers
    mssql = {
      source  = "betr-io/mssql"
      version = ">= 0.2.5"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2, >= 1.2.22"
    }
  }
}
