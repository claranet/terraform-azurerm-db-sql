data "azurerm_storage_account" "logs_storage" {
  name                = "${var.logs_storage_account_name}"
  resource_group_name = "${var.logs_storage_account_rg}"
}

resource "azurerm_sql_server" "server" {
  name = "${local.server_name}"

  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  version                      = "${var.version}"
  administrator_login          = "${var.administrator_login}"
  administrator_login_password = "${var.administrator_password}"

  tags = "${merge(local.default_tags, var.extra_tags, var.server_extra_tags)}"
}

# TODO Manage multiple databases
resource "azurerm_sql_database" "db" {
  name                = "${var.database_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  server_name = "${azurerm_sql_server.server.name}"

  collation                        = "${var.databases_collation}"
  edition                          = "${lookup(var.database_sku, "tier")}"
  requested_service_objective_name = "${lookup(var.database_sku, "size")}"
  max_size_bytes                   = "${var.database_max_size}"

  tags = "${merge(local.default_tags, var.extra_tags, var.database_extra_tags)}"
}

# TODO Manage Log Analytics
resource "azurerm_monitor_diagnostic_setting" "log_settings" {
  name               = "logs"
  target_resource_id = "${azurerm_sql_database.db.id}"

  storage_account_id = "${data.azurerm_storage_account.logs_storage.id}"

  log {
    category = "SQLInsights"

    "retention_policy" {
      enabled = true
      days    = "${var.logs_retention}"
    }
  }

  log {
    category = "AutomaticTuning"

    "retention_policy" {
      enabled = true
      days    = "${var.logs_retention}"
    }
  }

  log {
    category = "QueryStoreRuntimeStatistics"

    "retention_policy" {
      enabled = true
      days    = "${var.logs_retention}"
    }
  }

  log {
    category = "QueryStoreWaitStatistics"

    "retention_policy" {
      enabled = true
      days    = "${var.logs_retention}"
    }
  }

  log {
    category = "Errors"

    "retention_policy" {
      enabled = true
      days    = "${var.logs_retention}"
    }
  }

  log {
    category = "DatabaseWaitStatistics"

    "retention_policy" {
      enabled = true
      days    = "${var.logs_retention}"
    }
  }

  log {
    category = "Timeouts"

    "retention_policy" {
      enabled = true
      days    = "${var.logs_retention}"
    }
  }

  log {
    category = "Blocks"

    "retention_policy" {
      enabled = true
      days    = "${var.logs_retention}"
    }
  }

  log {
    category = "Deadlocks"

    "retention_policy" {
      enabled = true
      days    = "${var.logs_retention}"
    }
  }

  log {
    category = "Audit"

    "retention_policy" {
      enabled = true
      days    = "${var.logs_retention}"
    }
  }

  log {
    category = "SQLSecurityAuditEvents"

    "retention_policy" {
      enabled = true
      days    = "${var.logs_retention}"
    }
  }
}
