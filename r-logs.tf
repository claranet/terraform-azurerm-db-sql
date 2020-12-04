module "db_logging" {
  for_each = toset(var.databases_names)

  source  = "claranet/diagnostic-settings/azurerm"
  version = "4.0.1"

  resource_id           = azurerm_sql_database.db[each.key].id
  logs_destinations_ids = var.logs_destinations_ids
}

module "pool_logging" {
  source  = "claranet/diagnostic-settings/azurerm"
  version = "4.0.1"

  resource_id           = azurerm_mssql_elasticpool.elastic_pool.id
  logs_destinations_ids = var.logs_destinations_ids
}
