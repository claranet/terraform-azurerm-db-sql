terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azurecaf = {
      source  = "claranet/azurecaf"
      version = "~> 1.2.28"
    }
    # tflint-ignore: terraform_unused_required_providers
    mssql = {
      source  = "betr-io/mssql"
      version = "~> 0.2.5"
    }
  }
}
