module "db_logging" {
  for_each = { for db in var.databases_configuration : db.name => db }

  source  = "claranet/diagnostic-settings/azurerm"
  version = "4.0.3"

  resource_id           = azurerm_mssql_database.db[each.key].id
  logs_destinations_ids = var.logs_destinations_ids
}

module "pool_logging" {
  count   = var.logs_destinations_ids != [] && var.elasticpool_enabled ? 1 : 0
  source  = "claranet/diagnostic-settings/azurerm"
  version = "4.0.3"

  resource_id           = azurerm_mssql_elasticpool.elastic_pool[0].id
  logs_destinations_ids = var.logs_destinations_ids
}

module "single_db_logging" {
  for_each = { for db in var.single_databases_configuration : db.name => db if length(var.logs_destinations_ids) > 0 && var.enable_elasticpool == false }

  source  = "claranet/diagnostic-settings/azurerm"
  version = "4.0.3"

  logs_destinations_ids = var.logs_destinations_ids
  resource_id           = azurerm_mssql_database.single_database[each.key].id
}
