module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure_region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

module "logs" {
  source  = "claranet/run-common/azurerm//modules/logs"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  resource_group_name = module.rg.resource_group_name
}

resource "random_password" "admin_password" {
  special          = true
  override_special = "#$%&-_+{}<>:"
  upper            = true
  lower            = true
  number           = true
  length           = 32
}

# Elastic Pool
module "sql_elastic" {
  source  = "claranet/db-sql/azurerm"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  stack               = var.stack
  resource_group_name = module.rg.resource_group_name

  administrator_login    = "adminsqltest"
  administrator_password = random_password.admin_password.result
  create_databases_users = true

  elastic_pool_enabled  = true
  elastic_pool_max_size = "50"
  elastic_pool_sku = {
    tier     = "GeneralPurpose"
    capacity = 2
  }

  logs_destinations_ids = [
    module.logs.log_analytics_workspace_id,
    module.logs.logs_storage_account_id,
  ]

  databases = [
    {
      name        = "db1"
      max_size_gb = 50
    },
    {
      name        = "db2"
      max_size_gb = 180
    }
  ]

  custom_users = [
    {
      database = "db1"
      name     = "db1_custom1"
      roles    = ["db_accessadmin", "db_securityadmin"]
    },
    {
      database = "db1"
      name     = "db1_custom2"
      roles    = ["db_accessadmin", "db_securityadmin"]
    },
    {
      database = "db2"
      name     = "db2_custom1"
      roles    = []
    },
    {
      database = "db2"
      name     = "db2_custom2"
      roles    = ["db_accessadmin", "db_securityadmin"]
    }
  ]
}

# Single Database

module "sql_single" {
  source  = "claranet/db-sql/azurerm"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  stack               = var.stack
  resource_group_name = module.rg.resource_group_name

  administrator_login    = "adminsqltest"
  administrator_password = random_password.admin_password.result
  create_databases_users = true

  elastic_pool_enabled = false

  logs_destinations_ids = [
    module.logs.log_analytics_workspace_id,
    module.logs.logs_storage_account_id,
  ]

  databases = [
    {
      name        = "db1"
      max_size_gb = 50
    },
    {
      name        = "db2"
      max_size_gb = 180
    }
  ]

  custom_users = [
    {
      database = "db1"
      name     = "db1_custom1"
      roles    = ["db_accessadmin", "db_securityadmin"]
    },
    {
      database = "db1"
      name     = "db1_custom2"
      roles    = ["db_accessadmin", "db_securityadmin"]
    },
    {
      database = "db2"
      name     = "db2_custom1"
      roles    = []
    },
    {
      database = "db2"
      name     = "db2_custom2"
      roles    = ["db_accessadmin", "db_securityadmin"]
    }
  ]
}
