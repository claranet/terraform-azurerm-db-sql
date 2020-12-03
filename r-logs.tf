module "db_logging" {
  for_each = toset(var.logs_destinations_ids != [] ? var.databases_names : [])

  source  = "claranet/diagnostic-settings/azurerm"
  version = "4.0.1"

  resource_id           = azurerm_sql_database.db[each.key].id
  logs_destinations_ids = var.logs_destinations_ids
}

module "pool_logging" {
  count = var.logs_destinations_ids != [] ? 1 : 0

  source  = "claranet/diagnostic-settings/azurerm"
  version = "4.0.1"

  resource_id           = azurerm_mssql_elasticpool.elastic_pool.id
  logs_destinations_ids = var.logs_destinations_ids
}
