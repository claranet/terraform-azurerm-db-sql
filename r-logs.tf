resource "azurerm_monitor_diagnostic_setting" "log_settings_storage" {
  count = var.enable_logs_to_storage ? length(var.databases_names) : 0

  name               = "logs-storage"
  target_resource_id = azurerm_sql_database.db[count.index].id

  storage_account_id = var.logs_storage_account_id

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

resource "azurerm_monitor_diagnostic_setting" "log_settings_log_analytics" {
  count = var.enable_logs_to_log_analytics ? length(var.databases_names) : 0

  name               = "logs-log-analytics"
  target_resource_id = azurerm_sql_database.db[count.index].id

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
