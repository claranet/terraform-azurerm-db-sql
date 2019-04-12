resource "azurerm_sql_server" "server" {
  name = "${local.server_name}"

  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  version                      = "${var.version}"
  administrator_login          = "${var.administrator_login}"
  administrator_login_password = "${var.administrator_password}"

  tags = "${merge(local.default_tags, var.extra_tags, var.server_extra_tags)}"
}

resource "azurerm_sql_firewall_rule" "firewall_rule" {
  count = "${length(var.allowed_cidr_list)}"

  name                = "rule-${count.index}"
  resource_group_name = "${var.resource_group_name}"
  server_name         = "${azurerm_sql_server.server.name}"

  start_ip_address = "${cidrhost(element(var.allowed_cidr_list, count.index), 0)}"
  end_ip_address   = "${cidrhost(element(var.allowed_cidr_list, count.index), -1)}"
}

resource "azurerm_mssql_elasticpool" "elastic_pool" {
  name = "${local.elastic_pool_name}"

  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  server_name = "${azurerm_sql_server.server.name}"

  per_database_settings {
    max_capacity = "${coalesce(var.database_max_dtu_capacity, lookup(var.sku, "capacity"))}"
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

  threat_detection_policy {
    email_account_admins = "${var.enable_advanced_data_security_admin_emails ? "Enabled" : "Disabled"}"
    email_addresses      = "${var.advanced_data_security_additional_emails}"
    state                = "${var.enable_advanced_data_security ? "Enabled" : "Disabled"}"
  }

  tags = "${merge(local.default_tags, var.extra_tags, var.databases_extra_tags)}"
}
