data "azurecaf_name" "sql" {
  name          = var.stack
  resource_type = "azurerm_mssql_server"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.location_short, var.environment, local.name_suffix, var.use_caf_naming ? "" : "sql"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

data "azurecaf_name" "sql_pool" {
  name          = var.stack
  resource_type = "azurerm_mssql_elasticpool"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.location_short, var.environment, local.name_suffix, var.use_caf_naming ? "" : "pool"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

data "azurecaf_name" "sql_dbs" {
  for_each = try({ for database in var.databases : database.name => database }, {})

  name          = var.stack
  resource_type = "azurerm_mssql_database"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.location_short, var.environment, local.name_suffix, each.key, var.use_caf_naming ? "" : "sqldb"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}
