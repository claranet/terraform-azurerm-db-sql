terraform {
  required_version = ">= 1.3"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
    }
    mssql = {
      source  = "betr-io/mssql"
      version = ">= 0.2.5"
    }
  }
}
