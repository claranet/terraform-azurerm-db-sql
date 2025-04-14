resource "azurerm_mssql_server_security_alert_policy" "main" {
  count = var.sql_server_security_alerting_enabled ? 1 : 0

  resource_group_name = var.resource_group_name
  server_name         = azurerm_mssql_server.main.name
  state               = "Enabled"
}

resource "azurerm_mssql_server_vulnerability_assessment" "main" {
  count = var.sql_server_vulnerability_assessment_enabled ? 1 : 0

  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.main[0].id
  storage_container_path          = format("%s%s/", var.security_storage_account_blob_endpoint, var.security_storage_account_container_name)
  storage_account_access_key      = var.security_storage_account_access_key

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    emails                    = var.alerting_email_addresses
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "main" {
  count = var.sql_server_extended_auditing_enabled ? 1 : 0

  server_id                               = azurerm_mssql_server.main.id
  storage_endpoint                        = var.security_storage_account_blob_endpoint
  storage_account_access_key              = var.security_storage_account_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.sql_server_extended_auditing_retention_days
}

resource "azurerm_mssql_database_extended_auditing_policy" "db" {
  for_each = var.databases_extended_auditing_enabled ? try({ for db in var.databases : db.name => db }, {}) : {}

  database_id                             = azurerm_mssql_database.main[each.key].id
  storage_endpoint                        = var.security_storage_account_blob_endpoint
  storage_account_access_key              = var.security_storage_account_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.databases_extended_auditing_retention_days
}

moved {
  from = azurerm_mssql_server_security_alert_policy.sql_server["enabled"]
  to   = azurerm_mssql_server_security_alert_policy.main[0]
}
moved {
  from = azurerm_mssql_server_vulnerability_assessment.sql_server["enabled"]
  to   = azurerm_mssql_server_vulnerability_assessment.main[0]
}
moved {
  from = azurerm_mssql_server_extended_auditing_policy.sql_server["enabled"]
  to   = azurerm_mssql_server_extended_auditing_policy.main[0]
}
