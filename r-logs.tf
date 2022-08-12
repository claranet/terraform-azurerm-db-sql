module "pool_logging" {
  count = var.logs_destinations_ids != toset([]) && var.elastic_pool_enabled ? 1 : 0

  source  = "claranet/diagnostic-settings/azurerm"
  version = "5.0.0"

  resource_id           = azurerm_mssql_elasticpool.elastic_pool[0].id
  logs_destinations_ids = var.logs_destinations_ids

  retention_days = var.logs_retention_days
}

module "single_db_logging" {
  for_each = { for db in var.databases : db.name => db if var.logs_destinations_ids != toset([]) && var.elastic_pool_enabled == false }

  source  = "claranet/diagnostic-settings/azurerm"
  version = "5.0.0"

  logs_destinations_ids = var.logs_destinations_ids
  resource_id           = azurerm_mssql_database.single_database[each.key].id

  retention_days = var.logs_retention_days
}

module "elastic_pool_db_logging" {
  for_each = { for db in var.databases : db.name => db if var.logs_destinations_ids != toset([]) && var.elastic_pool_enabled == true }

  source  = "claranet/diagnostic-settings/azurerm"
  version = "5.0.0"

  logs_destinations_ids = var.logs_destinations_ids
  resource_id           = azurerm_mssql_database.elastic_pool_database[each.key].id

  retention_days = var.logs_retention_days
}
