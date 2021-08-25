module "db_logging" {
  for_each = toset(var.logs_destinations_ids != [] && var.enable_elasticpool ? var.elasticpool_databases : [])

  source  = "claranet/diagnostic-settings/azurerm"
  version = "4.0.1"

  resource_id           = azurerm_sql_database.db[each.key].id
  logs_destinations_ids = var.logs_destinations_ids
}

module "pool_logging" {
  count   = var.logs_destinations_ids != [] && var.enable_elasticpool ? 1 : 0
  source  = "claranet/diagnostic-settings/azurerm"
  version = "4.0.1"

  resource_id           = azurerm_mssql_elasticpool.elastic_pool[0].id
  logs_destinations_ids = var.logs_destinations_ids
}

module "single_db_logging" {
  for_each = { for db in var.single_databases_configuration : db.name => db if var.logs_destinations_ids != [] && var.enable_elasticpool == false }

  source  = "claranet/diagnostic-settings/azurerm"
  version = "4.0.1"

  logs_destinations_ids = var.logs_destinations_ids
  resource_id           = azurerm_mssql_database.single_database[each.key].id
}
