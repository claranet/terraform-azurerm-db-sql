resource "azurerm_sql_server" "server" {
  name = local.server_name

  location            = var.location
  resource_group_name = var.resource_group_name

  version                      = var.server_version
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_password

  tags = merge(local.default_tags, var.extra_tags, var.server_extra_tags)
}

resource "azurerm_sql_firewall_rule" "firewall_rule" {
  count = length(var.allowed_cidr_list)

  name                = "rule-${count.index}"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.server.name

  start_ip_address = cidrhost(var.allowed_cidr_list[count.index], 0)
  end_ip_address   = cidrhost(var.allowed_cidr_list[count.index], -1)
}

resource "azurerm_mssql_elasticpool" "elastic_pool" {
  count = var.enable_elasticpool ? 1 : 0
  name  = local.elastic_pool_name

  location            = var.location
  resource_group_name = var.resource_group_name

  server_name = azurerm_sql_server.server.name

  per_database_settings {
    max_capacity = coalesce(var.database_max_capacity, var.sku.capacity)
    min_capacity = var.database_min_capacity
  }

  max_size_gb    = var.elastic_pool_max_size
  zone_redundant = var.zone_redundant

  sku {
    capacity = local.elastic_pool_sku.capacity
    name     = local.elastic_pool_sku.name
    tier     = local.elastic_pool_sku.tier
    family   = local.elastic_pool_sku.family
  }

  tags = merge(local.default_tags, var.extra_tags, var.server_extra_tags)
}

resource "azurerm_sql_database" "db" {
  for_each = var.enable_elasticpool ? toset(var.elasticpool_databases) : []

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name

  server_name = azurerm_sql_server.server.name
  collation   = var.databases_collation

  requested_service_objective_name = "ElasticPool"
  elastic_pool_name                = azurerm_mssql_elasticpool.elastic_pool[0].name

  threat_detection_policy {
    email_account_admins = var.enable_advanced_data_security_admin_emails ? "Enabled" : "Disabled"
    email_addresses      = var.advanced_data_security_additional_emails
    state                = var.enable_advanced_data_security ? "Enabled" : "Disabled"
  }

  tags = merge(local.default_tags, var.extra_tags, var.databases_extra_tags)
}

resource "azurerm_sql_virtual_network_rule" "vnet_rule" {
  for_each            = { for subnet in local.allowed_subnets : subnet.name => subnet }
  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.server.name
  subnet_id           = each.value.subnet_id
}

resource "azurerm_mssql_database" "single_database" {
  for_each  = { for db in local.single_databases_configuration : db.name => db }
  name      = each.key
  server_id = azurerm_sql_server.server.id

  sku_name = each.value.sku_name

  collation = each.value.collation

  max_size_gb                 = each.value.max_size_gb
  zone_redundant              = lookup(each.value, "zone_redundant", false)
  min_capacity                = lookup(each.value, "min_capacity", null)
  auto_pause_delay_in_minutes = lookup(each.value, "auto_pause_delay_in_minutes", null)

  dynamic "threat_detection_policy" {
    for_each = each.value.threat_detection_policy.state == "Enabled" ? ["fake"] : []
    content {
      state                = each.value.threat_detection_policy.state
      email_account_admins = lookup(each.value.threat_detection_policy, "email_account_admins", "Disabled")
      email_addresses      = lookup(each.value.threat_detection_policy, "email_addresses", "john.doe@azure.com")
    }
  }

  short_term_retention_policy {
    retention_days = each.value.retention_days
  }

  dynamic "long_term_retention_policy" {
    for_each = coalesce(
      lookup(each.value, "weekly_retention", ""),
      lookup(each.value, "monthly_retention", ""),
      lookup(each.value, "yearly_retention", ""),
      lookup(each.value, "week_of_year", ""),
      "empty"
    ) == "empty" ? [] : ["fake"]
    content {
      weekly_retention  = lookup(each.value, "weekly_retention", null)
      monthly_retention = lookup(each.value, "montly_retention", null)
      yearly_retention  = lookup(each.value, "yearly_retention", null)
      week_of_year      = lookup(each.value, "week_of_year", null)
    }
  }

  tags = merge(local.default_tags, var.extra_tags, lookup(each.value, "database_extra_tags", {}))

}
