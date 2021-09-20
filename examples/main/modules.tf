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

module "sql_dtu" {
  source  = "claranet/db-sql/azurerm"
  version = "x.x.x"

  client_name    = var.client_name
  environment    = var.environment
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  elasticpool_databases = ["users", "documents"]

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  sku = {
    # Tier Basic/Standard/Premium are based on DTU
    tier     = "Standard"
    capacity = "100"
  }

  elastic_pool_max_size = "50"

  # This can costs you money https://docs.microsoft.com/en-us/azure/sql-database/sql-database-advanced-data-security
  enable_advanced_data_security = true

  logs_destinations_ids = [
    module.logs.log_analytics_workspace_id,
    module.logs.logs_storage_account_id,
  ]
}

module "sql_vcore" {
  source  = "claranet/db-sql/azurerm"
  version = "x.x.x"

  client_name    = var.client_name
  environment    = var.environment
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  sku = {
    # GeneralPurpose or BusinessCritical will actiate the vCore based model on Gen5 hardware
    tier     = "GeneralPurpose"
    capacity = 2
  }

  elastic_pool_max_size = "50"

  logs_destinations_ids = [
    module.logs.log_analytics_workspace_id,
    module.logs.logs_storage_account_id
  ]

  allowed_subnets_ids = [
    "/subscriptions/xxxxxx/resourceGroups/xxxxxx/providers/Microsoft.Network/virtualNetworks/vnetxxxxxx/subnets/subnetxxxxx",
  ]
}

module "sql_custom_users" {
  source  = "claranet/db-sql/azurerm"
  version = "x.x.x"

  client_name    = var.client_name
  environment    = var.environment
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  sku = {
    # GeneralPurpose or BusinessCritical will actiate the vCore based model on Gen5 hardware
    tier     = "GeneralPurpose"
    capacity = 2
  }

  elastic_pool_max_size = "50"

  logs_destinations_ids = [
    module.logs.log_analytics_workspace_id,
    module.logs.logs_storage_account_id
  ]

  custom_users = [
    {
      name     = "User1"
      database = "MyDB1"
      roles    = ["db_datareader", "db_datawriter"]
    },
    {
      name     = "UserAdmin"
      database = "MyDB1"
      roles    = ["db_owner"]
    }
  ]
}

module "sql_single" {
  source  = "claranet/db-sql/azurerm"
  version = "x.x.x"

  client_name    = var.client_name
  environment    = var.environment
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  single_databases_configuration = [
    {
      name                        = "document"
      max_size_gb                 = 100
      sku_name                    = "GP_S_Gen5_4"
      min_capacity                = 0.5
      auto_pause_delay_in_minutes = 60
      storage_account_type        = "GRS"
      retention_days              = 14
    },
    {
      name                        = "users"
      max_size_gb                 = 100
      sku_name                    = "GP_S_Gen5_4"
      min_capacity                = 0.5
      auto_pause_delay_in_minutes = 60
      storage_account_type        = "GRS"
      retention_days              = 14
    }
  ]

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  enable_elasticpool = false


  logs_destinations_ids = [
    module.logs.log_analytics_workspace_id,
    module.logs.logs_storage_account_id,
  ]
}
