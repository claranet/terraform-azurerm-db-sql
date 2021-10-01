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
