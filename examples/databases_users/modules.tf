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
  source  = "claranet/run/azurerm//modules/logs"
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
  create_databases_users = false

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
  ]
}

module "users" {
  for_each = {
    "app-db1" = {
      name     = "app"
      database = "db1"
      roles    = ["db_accessadmin", "db_securityadmin"]
    }
  }

  source  = "claranet/db-sql/azurerm//modules/databases_users"
  version = "x.x.x"

  administrator_login    = "adminsqltest"
  administrator_password = random_password.admin_password.result

  sql_server_hostname = module.sql_single.sql_databases["db1"].fully_qualified_domain_name

  database_name = each.value.database
  user_name     = each.value.name
  user_roles    = each.value.roles
}
