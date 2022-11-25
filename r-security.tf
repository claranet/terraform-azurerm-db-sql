resource "azurerm_mssql_server_security_alert_policy" "sql_server" {
  for_each = toset(var.sql_server_security_alerting_enabled ? ["enabled"] : [])

  resource_group_name = var.resource_group_name
  server_name         = azurerm_mssql_server.sql.name
  state               = "Enabled"
}

resource "azurerm_mssql_server_vulnerability_assessment" "sql_server" {
  for_each = toset(var.sql_server_vulnerability_assessment_enabled ? ["enabled"] : [])

  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.sql_server["enabled"].id
  storage_container_path          = format("%s%s/", var.security_storage_account_blob_endpoint, var.security_storage_account_container_name)
  storage_account_access_key      = var.security_storage_account_access_key

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    emails                    = var.alerting_email_addresses
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "sql_server" {
  for_each = toset(var.sql_server_extended_auditing_enabled ? ["enabled"] : [])

  server_id                               = azurerm_mssql_server.sql.id
  storage_endpoint                        = var.security_storage_account_blob_endpoint
  storage_account_access_key              = var.security_storage_account_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.sql_server_extended_auditing_retention_days
}

resource "azurerm_mssql_database_extended_auditing_policy" "elastic_pool_db" {
  for_each = var.databases_extended_auditing_enabled ? try({ for db in var.databases : db.name => db if var.elastic_pool_enabled == true }, {}) : {}

  database_id                             = azurerm_mssql_database.elastic_pool_database[each.key].id
  storage_endpoint                        = var.security_storage_account_blob_endpoint
  storage_account_access_key              = var.security_storage_account_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.databases_extended_auditing_retention_days
}

resource "azurerm_mssql_database_extended_auditing_policy" "single_db" {
  for_each = var.databases_extended_auditing_enabled ? try({ for db in var.databases : db.name => db if var.elastic_pool_enabled == false }, {}) : {}

  database_id                             = azurerm_mssql_database.single_database[each.key].id
  storage_endpoint                        = var.security_storage_account_blob_endpoint
  storage_account_access_key              = var.security_storage_account_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.databases_extended_auditing_retention_days
}
