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
  count = var.elasticpool_enabled ? 1 : 0

  name = local.elastic_pool_name

  location            = var.location
  resource_group_name = var.resource_group_name

  license_type = var.elasticpool_license_type

  server_name = azurerm_sql_server.server.name

  per_database_settings {
    max_capacity = coalesce(var.elastic_pool_database_max_capacity, var.sku.capacity)
    min_capacity = var.elastic_pool_database_min_capacity
  }

  max_size_gb    = var.elastic_pool_max_size
  zone_redundant = var.elastic_pool_zone_redundant

  sku {
    capacity = local.elastic_pool_sku.capacity
    name     = local.elastic_pool_sku.name
    tier     = local.elastic_pool_sku.tier
    family   = local.elastic_pool_sku.family
  }

  tags = merge(local.default_tags, var.extra_tags, var.elastic_pool_extra_tags)
}

resource "azurerm_sql_virtual_network_rule" "vnet_rule" {
  for_each            = { for subnet in local.allowed_subnets : subnet.name => subnet }
  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.server.name
  subnet_id           = each.value.subnet_id
}
