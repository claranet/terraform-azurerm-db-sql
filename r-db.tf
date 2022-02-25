resource "azurerm_mssql_database" "single_database" {
  for_each = { for db in var.databases : db.name => db if !var.elastic_pool_enabled }

  name      = each.key
  server_id = azurerm_mssql_server.sql.id

  sku_name     = var.single_databases_sku_name
  license_type = each.value.license_type

  collation      = var.databases_collation
  max_size_gb    = can(regex("Secondary|OnlineSecondary", each.value.create_mode)) ? null : each.value.max_size_gb
  zone_redundant = can(regex("^DW", var.single_databases_sku_name)) && var.databases_zone_redundant != null ? var.databases_zone_redundant : false

  min_capacity                = can(regex("^GP_S", var.single_databases_sku_name)) ? each.value.min_capacity : null
  auto_pause_delay_in_minutes = can(regex("^GP_S", var.single_databases_sku_name)) ? each.value.auto_pause_delay_in_minutes : null

  read_scale         = can(regex("^P|BC", var.single_databases_sku_name)) && lookup(each.value, "read_scale", null) != null ? each.value.read_scale : false
  read_replica_count = can(regex("^HS", var.single_databases_sku_name)) ? lookup(each.value, "read_replica_count", null) : null

  #https://docs.microsoft.com/en-us/dotnet/api/microsoft.azure.management.sql.models.database.createmode?view=azure-dotnet
  create_mode = can(regex("^DW", var.single_databases_sku_name)) ? lookup(local.datawarehouse_allowed_create_mode, each.value.create_mode, "Default") : try(lookup(local.standard_allowed_create_mode, each.value.create_mode), "Default")

  creation_source_database_id = can(regex("Copy|Secondary|PointInTimeRestore|Recovery|RestoreExternalBackup|Restore|RestoreExternalBackupSecondary", each.value.create_mode)) ? each.value.creation_source_database_id : null

  restore_point_in_time       = lookup(each.value, "create_mode", null) == "PointInTimeRestore" ? each.value.restore_point_in_time : null
  recover_database_id         = lookup(each.value, "create_mode", null) == "Recovery" ? each.value.recover_database_id : null
  restore_dropped_database_id = lookup(each.value, "create_mode", null) == "Restore" ? each.value.restore_dropped_database_id : null

  storage_account_type = lookup(each.value, "storage_account_type", local.storage_account_type)

  dynamic "threat_detection_policy" {
    for_each = var.threat_detection_policy_enabled ? ["enabled"] : []
    content {
      state                      = "Enabled"
      email_account_admins       = "Enabled"
      email_addresses            = var.alerting_email_addresses
      retention_days             = var.threat_detection_policy_retention_days
      disabled_alerts            = var.threat_detection_policy_disabled_alerts
      storage_endpoint           = var.security_storage_account_blob_endpoint
      storage_account_access_key = var.security_storage_account_access_key
    }
  }

  short_term_retention_policy {
    retention_days = var.point_in_time_restore_retention_days
  }

  dynamic "long_term_retention_policy" {
    for_each = coalesce(
      lookup(var.backup_retention, "weekly_retention", ""),
      lookup(var.backup_retention, "monthly_retention", ""),
      lookup(var.backup_retention, "yearly_retention", ""),
      lookup(var.backup_retention, "week_of_year", ""),
      "empty"
    ) == "empty" ? [] : ["fake"]
    content {
      weekly_retention  = lookup(var.backup_retention, "weekly_retention", null)
      monthly_retention = lookup(var.backup_retention, "monthly_retention", null)
      yearly_retention  = lookup(var.backup_retention, "yearly_retention", null)
      week_of_year      = lookup(var.backup_retention, "week_of_year", null)
    }
  }

  tags = merge(local.default_tags, var.extra_tags, lookup(each.value, "database_extra_tags", {}))
}

resource "azurerm_mssql_database" "elastic_pool_database" {
  for_each = { for db in var.databases : db.name => db if var.elastic_pool_enabled }

  name      = each.key
  server_id = azurerm_mssql_server.sql.id

  sku_name        = "ElasticPool"
  license_type    = each.value.license_type
  elastic_pool_id = azurerm_mssql_elasticpool.elastic_pool[0].id

  collation      = var.databases_collation
  max_size_gb    = can(regex("Secondary|OnlineSecondary", each.value.create_mode)) ? null : each.value.max_size_gb
  zone_redundant = can(regex("^DW", var.single_databases_sku_name)) && var.databases_zone_redundant != null ? var.databases_zone_redundant : false

  #https://docs.microsoft.com/en-us/dotnet/api/microsoft.azure.management.sql.models.database.createmode?view=azure-dotnet
  create_mode = try(lookup(local.standard_allowed_create_mode, each.value.create_mode), "Default")

  creation_source_database_id = can(regex("Copy|Secondary|PointInTimeRestore|Recovery|RestoreExternalBackup|Restore|RestoreExternalBackupSecondary", each.value.create_mode)) ? each.value.creation_source_database_id : null

  restore_point_in_time       = lookup(each.value, "create_mode", null) == "PointInTimeRestore" ? each.value.restore_point_in_time : null
  recover_database_id         = lookup(each.value, "create_mode", null) == "Recovery" ? each.value.recover_database_id : null
  restore_dropped_database_id = lookup(each.value, "create_mode", null) == "Restore" ? each.value.restore_dropped_database_id : null

  storage_account_type = lookup(each.value, "storage_account_type", local.storage_account_type)

  dynamic "threat_detection_policy" {
    for_each = var.threat_detection_policy_enabled ? ["enabled"] : []
    content {
      state                      = "Enabled"
      email_account_admins       = "Enabled"
      email_addresses            = var.alerting_email_addresses
      retention_days             = var.threat_detection_policy_retention_days
      disabled_alerts            = var.threat_detection_policy_disabled_alerts
      storage_endpoint           = var.security_storage_account_blob_endpoint
      storage_account_access_key = var.security_storage_account_access_key
    }
  }

  short_term_retention_policy {
    retention_days = var.point_in_time_restore_retention_days
  }

  dynamic "long_term_retention_policy" {
    for_each = coalesce(
      lookup(var.backup_retention, "weekly_retention", ""),
      lookup(var.backup_retention, "monthly_retention", ""),
      lookup(var.backup_retention, "yearly_retention", ""),
      lookup(var.backup_retention, "week_of_year", ""),
      "empty"
    ) == "empty" ? [] : ["fake"]
    content {
      weekly_retention  = lookup(var.backup_retention, "weekly_retention", null)
      monthly_retention = lookup(var.backup_retention, "monthly_retention", null)
      yearly_retention  = lookup(var.backup_retention, "yearly_retention", null)
      week_of_year      = lookup(var.backup_retention, "week_of_year", null)
    }
  }

  tags = merge(local.default_tags, var.extra_tags, lookup(each.value, "database_extra_tags", {}))
}
