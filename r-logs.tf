module "db_logging" {
  for_each = toset(var.logs_destinations_ids != [] ? var.databases_names : [])

  source = "git::ssh://git@git.fr.clara.net/claranet/projects/cloud/azure/terraform/modules/diagnostic-settings.git?ref=AZ-160-revamp"

  resource_id           = azurerm_sql_database.db[each.key].id
  logs_destinations_ids = var.logs_destinations_ids
}

module "pool_logging" {
  count = var.logs_destinations_ids != [] ? 1 : 0

  source = "git::ssh://git@git.fr.clara.net/claranet/projects/cloud/azure/terraform/modules/diagnostic-settings.git?ref=AZ-160-revamp"

  resource_id           = azurerm_mssql_elasticpool.elastic_pool.id
  logs_destinations_ids = var.logs_destinations_ids
}
