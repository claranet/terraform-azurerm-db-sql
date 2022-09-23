terraform {
  required_version = ">= 1.0, <1.3"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
    mssql = {
      source  = "betr-io/mssql"
      version = ">= 0.2.3"
    }
  }
}
