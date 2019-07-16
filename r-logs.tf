resource "azurerm_monitor_diagnostic_setting" "log_settings" {
  count = var.logs_storage_account_id != null || var.logs_log_analytics_workspace_id != null ? length(var.databases_names) : 0

  name               = "logs-settings"
  target_resource_id = azurerm_sql_database.db[count.index].id

  storage_account_id         = var.logs_storage_account_id
  log_analytics_workspace_id = var.logs_log_analytics_workspace_id

  dynamic "log" {
    for_each = local.log_categories
    content {
      category = log.value

      retention_policy {
        enabled = true
        days    = var.logs_storage_retention
      }
    }
  }

  metric {
    category = "Basic"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}
