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

resource "azurerm_mssql_elasticpool" "elastic_pool" {
  name = "${local.elastic_pool_name}"

  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  server_name = "${azurerm_sql_server.server.name}"

  per_database_settings {
    max_capacity = "${coalesce(var.database_max_dtu_capacity, var.sku_capacity)}"
    min_capacity = "${var.database_min_dtu_capacity}"
  }

  max_size_gb    = "${var.elastic_pool_max_size}"
  zone_redundant = "${var.zone_redundant}"

  sku = ["${local.elastic_pool_sku}"]

  tags = "${merge(local.default_tags, var.extra_tags, var.elastic_pool_extra_tags)}"
}

resource "azurerm_sql_database" "db" {
  count = "${length(var.databases_names)}"

  name                = "${element(var.databases_names, count.index)}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  server_name = "${azurerm_sql_server.server.name}"
  collation   = "${var.databases_collation}"

  requested_service_objective_name = "ElasticPool"
  elastic_pool_name                = "${azurerm_mssql_elasticpool.elastic_pool.name}"

  # FIXME make this works if it can
  # threat_detection_policy {}

  tags = "${merge(local.default_tags, var.extra_tags, var.databases_extra_tags)}"
}

# TODO Manage Log Analytics
resource "azurerm_monitor_diagnostic_setting" "log_settings" {
  count = "${length(var.databases_names)}"

  name               = "logs"
  target_resource_id = "${element(azurerm_sql_database.db.*.id, count.index)}"

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

  # FIXME Do not work ? https://github.com/MicrosoftDocs/azure-docs/issues/29071
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

  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
}
