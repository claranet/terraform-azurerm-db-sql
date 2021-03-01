resource "azurerm_mssql_database" "db" {
  for_each  = { for db in var.databases_configuration : db.name => db }
  name      = each.key
  server_id = azurerm_sql_server.server.id

  sku_name     = each.value.elastic_pool_enabled != false ? "ElasticPool" : coalesce(each.value.sku_name, local.default_sku)
  license_type = each.value.license_type

  collation = each.value.collation == null ? local.default_collation : each.value.collation

  max_size_gb    = can(regex("Secondary|OnlineSecondary", each.value.create_mode)) ? null : each.value.max_size_gb
  zone_redundant = can(regex("^DW", each.value.sku_name)) && each.value.zone_redundant != null ? each.value.zone_redundant : false

  min_capacity                = can(regex("^GP_S", each.value.sku_name)) ? each.value.min_capacity : null
  auto_pause_delay_in_minutes = can(regex("^GP_S", each.value.sku_name)) ? each.value.auto_pause_delay_in_minutes : null

  elastic_pool_id = try(each.value.elastic_pool_enabled, false) ? azurerm_mssql_elasticpool.elastic_pool[0].id : null

  read_scale         = can(regex("^P|BC", each.value.sku_name)) && each.value.read_scale != null ? each.value.read_scale : false
  read_replica_count = can(regex("^HS", each.value.sku_name)) ? each.value.read_replica_count : null

  #https://docs.microsoft.com/en-us/dotnet/api/microsoft.azure.management.sql.models.database.createmode?view=azure-dotnet
  create_mode = can(regex("^DW", each.value.sku_name)) ? lookup(local.datawarehouse_allowed_create_mode, each.value.create_mode, "Default") : lookup(local.standard_allowed_create_mode, each.value.create_mode, "Default")

  creation_source_database_id = can(regex("Copy|Secondary|PointInTimeRestore|Recovery|RestoreExternalBackup|Restore|RestoreExternalBackupSecondary", each.value.create_mode)) ? each.value.creation_source_database_id : null

  restore_point_in_time       = each.value.create_mode == "PointInTimeRestore" ? each.value.restore_point_in_time : null
  recover_database_id         = each.value.create_mode == "Recovery" ? each.value.recover_database_id : null
  restore_dropped_database_id = each.value.create_mode == "Restore" ? each.value.restore_dropped_database_id : null

  dynamic "threat_detection_policy" {
    for_each = each.value.threat_detection_policy.state == "Enabled" ? ["enabled"] : []
    content {
      disabled_alerts            = each.value.threat_detection_policy.disabled_alerts
      email_account_admins       = each.value.threat_detection_policy.email_account_admins
      email_addresses            = each.value.threat_detection_policy.email_addresses
      retention_days             = each.value.threat_detection_policy.retention_days
      state                      = each.value.threat_detection_policy.state
      storage_account_access_key = each.value.threat_detection_policy.storage_account_access_key
      storage_endpoint           = each.value.threat_detection_policy.storage_endpoint
      use_server_default         = each.value.threat_detection_policy.use_server_default
    }
  }

  storage_account_type = each.value.storage_account_type == null ? local.storage_account_type : each.value.storage_account_type

  dynamic "short_term_retention_policy" {
    for_each = each.value.short_term_retention_policy != null ? ["enabled"] : []
    content {
      retention_days = each.value.short_term_retention_policy.retention_days
    }
  }

  dynamic "long_term_retention_policy" {
    for_each = each.value.long_term_retention_policy != null ? ["enabled"] : []

    content {
      weekly_retention  = lookup(each.value.long_term_retention_policy, "weekly_retention", null)
      monthly_retention = lookup(each.value.long_term_retention_policy, "montly_retention", null)
      yearly_retention  = lookup(each.value.long_term_retention_policy, "yearly_retention", null)
      week_of_year      = lookup(each.value.long_term_retention_policy, "week_of_year", null)
    }
  }

  tags = merge(local.default_tags, var.extra_tags, lookup(each.value, "database_extra_tags", {}))

}
