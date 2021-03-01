locals {
  databases_configuration = [
    {
      name                        = "db1"
      create_mode                 = "Default"
      max_size_gb                 = "10"
      min_capacity                = "3"
      auto_pause_delay_in_minutes = "3"
      elastic_pool_enabled        = true
      retention_days              = "20"
      database_extra_tags = {
        "dbname" = "db1"
      }
      threat_detection_policy = {
        state = false
      }
    },
    {
      name                        = "db2"
      create_mode                 = "Default"
      max_size_gb                 = "10"
      auto_pause_delay_in_minutes = "3"
      elastic_pool_enabled        = false
      retention_days              = "20"
      sku_name                    = "GP_Gen5_2"
      database_extra_tags = {
        "tag1"   = "tag1value"
        "dbname" = "db2"
      }
      short_term_retention_policy = {
        retention_days = 20
      }
      long_term_retention_policy = {
        weekly_retention  = "P1M"
        monthly_retention = "P1Y"
        yearly_retention  = "P1Y"
        week_of_year      = "3"
      }
      threat_detection_policy = {
        state                      = "Enabled"
        email_addresses            = ["john@doe.net"]
        storage_endpoint           = "https://myaccount.blob.core.windows.net/"
        storage_account_access_key = "storage_account_access_key"
      }
      extended_auditing_policy = {
        retention_days = 8
      }
    },
  ]
  custom_users = [
    {
      database_name = "db1"
      user_name     = "db1_custom1"
      roles         = ["db_accessadmin", "db_securityadmin"]
    },
    {
      database_name = "db1"
      user_name     = "db1_custom2"
      roles         = ["db_accessadmin", "db_securityadmin"]
    },
    {
      database_name = "db2"
      user_name     = "db2_custom1"
      roles         = []
    },
    {
      database_name = "db2"
      user_name     = "db2_custom2"
      roles         = ["db_accessadmin", "db_securityadmin"]
    }
  ]
  administrator_login = "adminsqltest"
}



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


module "sql" {
  source  = "claranet/db-sql/azurerm"
  version = "x.x.x"

  client_name    = var.client_name
  environment    = var.environment
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  administrator_login    = local.administrator_login
  administrator_password = random_password.admin_password.result

  sku = {
    # Tier Basic/Standard/Premium are based on DTU
    tier     = "Standard"
    capacity = "100"
  }
  create_databases_users = true

  elasticpool_enabled   = true
  elastic_pool_max_size = "50"

  logs_destinations_ids = [
    module.logs.log_analytics_workspace_id,
    module.logs.logs_storage_account_id,
  ]

  databases_configuration = local.databases_configuration
  custom_users            = local.custom_users

}

