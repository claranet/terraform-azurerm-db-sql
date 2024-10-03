module "pool_logging" {
  count = var.logs_destinations_ids != toset([]) && var.elastic_pool_enabled ? 1 : 0

  source  = "claranet/diagnostic-settings/azurerm"
  version = "~> 7.0.0"

  resource_id = azurerm_mssql_elasticpool.elastic_pool[0].id

  logs_destinations_ids = var.logs_destinations_ids
  log_categories        = var.logs_categories
  metric_categories     = var.logs_metrics_categories

  use_caf_naming = var.use_caf_naming
  custom_name    = var.custom_diagnostic_settings_name
  name_prefix    = var.name_prefix
  name_suffix    = var.name_suffix
}

module "single_db_logging" {
  for_each = { for db in var.databases : db.name => db if var.logs_destinations_ids != toset([]) && var.elastic_pool_enabled == false }

  source  = "claranet/diagnostic-settings/azurerm"
  version = "~> 7.0.0"

  resource_id = azurerm_mssql_database.single_database[each.key].id

  logs_destinations_ids = var.logs_destinations_ids
  log_categories        = var.logs_categories
  metric_categories     = var.logs_metrics_categories

  use_caf_naming = var.use_caf_naming
  custom_name    = var.custom_diagnostic_settings_name
  name_prefix    = var.name_prefix
  name_suffix    = var.name_suffix
}

module "elastic_pool_db_logging" {
  for_each = { for db in var.databases : db.name => db if var.logs_destinations_ids != toset([]) && var.elastic_pool_enabled == true }

  source  = "claranet/diagnostic-settings/azurerm"
  version = "~> 7.0.0"

  resource_id = azurerm_mssql_database.elastic_pool_database[each.key].id

  logs_destinations_ids = var.logs_destinations_ids
  log_categories        = var.logs_categories
  metric_categories     = var.logs_metrics_categories

  use_caf_naming = var.use_caf_naming
  custom_name    = var.custom_diagnostic_settings_name
  name_prefix    = var.name_prefix
  name_suffix    = var.name_suffix
}
