resource "azurerm_monitor_diagnostic_setting" "log_settings_storage" {
  count = "${var.enable_logs_to_storage ? length(var.databases_names) : 0}"

  name               = "logs-storage"
  target_resource_id = "${element(azurerm_sql_database.db.*.id, count.index)}"

  storage_account_id = "${var.logs_storage_account_id}"

  log {
    category = "SQLInsights"

    retention_policy {
      enabled = true
      days    = "${var.logs_storage_retention}"
    }
  }

  log {
    category = "AutomaticTuning"

    retention_policy {
      enabled = true
      days    = "${var.logs_storage_retention}"
    }
  }

  log {
    category = "QueryStoreRuntimeStatistics"

    retention_policy {
      enabled = true
      days    = "${var.logs_storage_retention}"
    }
  }

  log {
    category = "QueryStoreWaitStatistics"

    retention_policy {
      enabled = true
      days    = "${var.logs_storage_retention}"
    }
  }

  log {
    category = "Errors"

    retention_policy {
      enabled = true
      days    = "${var.logs_storage_retention}"
    }
  }

  log {
    category = "DatabaseWaitStatistics"

    retention_policy {
      enabled = true
      days    = "${var.logs_storage_retention}"
    }
  }

  log {
    category = "Timeouts"

    retention_policy {
      enabled = true
      days    = "${var.logs_storage_retention}"
    }
  }

  log {
    category = "Blocks"

    retention_policy {
      enabled = true
      days    = "${var.logs_storage_retention}"
    }
  }

  log {
    category = "Deadlocks"

    retention_policy {
      enabled = true
      days    = "${var.logs_storage_retention}"
    }
  }

  # FIXME Do not work ? https://github.com/MicrosoftDocs/azure-docs/issues/29071
  log {
    category = "Audit"

    retention_policy {
      enabled = true
      days    = "${var.logs_storage_retention}"
    }
  }

  log {
    category = "SQLSecurityAuditEvents"

    retention_policy {
      enabled = true
      days    = "${var.logs_storage_retention}"
    }
  }

  metric {
    category = "Basic"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "log_settings_log_analytics" {
  count = "${var.enable_logs_to_log_analytics ? length(var.databases_names) : 0}"

  name               = "logs-log-analytics"
  target_resource_id = "${element(azurerm_sql_database.db.*.id, count.index)}"

  log_analytics_workspace_id = "${var.logs_log_analytics_workspace_id}"

  log {
    category = "SQLInsights"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AutomaticTuning"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "QueryStoreRuntimeStatistics"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "QueryStoreWaitStatistics"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "Errors"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "DatabaseWaitStatistics"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "Timeouts"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "Blocks"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "Deadlocks"

    retention_policy {
      enabled = false
    }
  }

  # FIXME Do not work ? https://github.com/MicrosoftDocs/azure-docs/issues/29071
  log {
    category = "Audit"

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "SQLSecurityAuditEvents"

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "Basic"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
}
