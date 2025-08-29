#tfsec:ignore:azure-database-enable-audit
resource "azurerm_mssql_server" "main" {
  name                = local.name
  resource_group_name = var.resource_group_name
  location            = var.location

  version                              = var.server_version
  connection_policy                    = var.connection_policy
  minimum_tls_version                  = var.tls_minimum_version
  public_network_access_enabled        = var.public_network_access_enabled
  outbound_network_restriction_enabled = var.outbound_network_restriction_enabled

  # Express vulnerability assessment setting cannot be applied along with classic SQL vulnerability assessment
  express_vulnerability_assessment_enabled = var.express_vulnerability_assessment_enabled

  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_password
  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator[*]
    content {
      login_username              = var.azuread_administrator.login_username
      object_id                   = var.azuread_administrator.object_id
      tenant_id                   = var.azuread_administrator.tenant_id
      azuread_authentication_only = var.azuread_administrator.azuread_authentication_only
    }
  }

  primary_user_assigned_identity_id = var.primary_user_assigned_identity_id

  dynamic "identity" {
    for_each = var.identity[*]
    content {
      type         = var.identity.type
      identity_ids = endswith(var.identity.type, "UserAssigned") ? var.identity.identity_ids : null
    }
  }

  tags = merge(local.default_tags, var.extra_tags, var.server_extra_tags)

  lifecycle {
    precondition {
      condition     = !(var.express_vulnerability_assessment_enabled && var.sql_server_vulnerability_assessment_enabled)
      error_message = "Classic SQL vulnerability assessment cannot be enabled when express vulnerability assessment is enabled."
    }
  }
}

resource "azurerm_mssql_firewall_rule" "main" {
  for_each = can(tomap(var.allowed_cidrs)) ? tomap(var.allowed_cidrs) : { for idx, cidr in var.allowed_cidrs : "rule-${idx}" => cidr }

  name      = each.key
  server_id = azurerm_mssql_server.main.id

  start_ip_address = cidrhost(each.value, 0)
  end_ip_address   = cidrhost(each.value, -1)
}

resource "azurerm_mssql_elasticpool" "main" {
  count = var.elastic_pool_enabled ? 1 : 0

  name = local.elastic_pool_name

  location            = var.location
  resource_group_name = var.resource_group_name

  license_type = var.elastic_pool_license_type

  server_name = azurerm_mssql_server.main.name

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

resource "azurerm_mssql_virtual_network_rule" "main" {
  for_each  = try({ for subnet in local.allowed_subnets : subnet.name => subnet }, {})
  name      = each.key
  server_id = azurerm_mssql_server.main.id
  subnet_id = each.value.subnet_id
}


moved {
  from = azurerm_mssql_server.sql
  to   = azurerm_mssql_server.main
}
moved {
  from = azurerm_mssql_firewall_rule.firewall_rule
  to   = azurerm_mssql_firewall_rule.main
}
moved {
  from = azurerm_mssql_elasticpool.elastic_pool
  to   = azurerm_mssql_elasticpool.main
}
moved {
  from = azurerm_mssql_virtual_network_rule.vnet_rule
  to   = azurerm_mssql_virtual_network_rule.main
}
