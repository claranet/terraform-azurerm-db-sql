#tfsec:ignore:azure-database-enable-audit
resource "azurerm_mssql_server" "sql" {
  name                = local.server_name
  resource_group_name = var.resource_group_name
  location            = var.location

  version                              = var.server_version
  connection_policy                    = var.connection_policy
  minimum_tls_version                  = var.tls_minimum_version
  public_network_access_enabled        = var.public_network_access_enabled
  outbound_network_restriction_enabled = var.outbound_network_restriction_enabled

  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_password
  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator != null ? ["enabled"] : []
    content {
      login_username              = var.azuread_administrator.login_username
      object_id                   = var.azuread_administrator.object_id
      tenant_id                   = var.azuread_administrator.tenant_id
      azuread_authentication_only = var.azuread_administrator.azuread_authentication_only
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(local.default_tags, var.extra_tags, var.server_extra_tags)
}

resource "azurerm_mssql_firewall_rule" "firewall_rule" {
  count = try(length(var.allowed_cidr_list), 0)

  name      = "rule-${count.index}"
  server_id = azurerm_mssql_server.sql.id

  start_ip_address = cidrhost(var.allowed_cidr_list[count.index], 0)
  end_ip_address   = cidrhost(var.allowed_cidr_list[count.index], -1)
}

resource "azurerm_mssql_elasticpool" "elastic_pool" {
  count = var.elastic_pool_enabled ? 1 : 0

  name = local.elastic_pool_name

  location            = var.location
  resource_group_name = var.resource_group_name

  license_type = var.elastic_pool_license_type

  server_name = azurerm_mssql_server.sql.name

  per_database_settings {
    max_capacity = coalesce(var.elastic_pool_databases_max_capacity, var.elastic_pool_sku.capacity)
    min_capacity = var.elastic_pool_databases_min_capacity
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

resource "azurerm_mssql_virtual_network_rule" "vnet_rule" {
  for_each  = try({ for subnet in local.allowed_subnets : subnet.name => subnet }, {})
  name      = each.key
  server_id = azurerm_mssql_server.sql.id
  subnet_id = each.value.subnet_id
}
