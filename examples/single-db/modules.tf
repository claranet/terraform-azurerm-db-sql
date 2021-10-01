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

module "sql" {
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
