terraform {
  experiments      = [module_variable_optional_attrs]
  required_version = ">= 0.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 1.31"
    }
  }
}
