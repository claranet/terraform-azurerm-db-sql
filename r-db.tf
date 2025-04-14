resource "azurerm_mssql_database" "single_database" {
  for_each = try({ for db in var.databases : db.name => db if !var.elastic_pool_enabled }, {})

  name      = var.use_caf_naming_for_databases ? data.azurecaf_name.sql_dbs[each.key].result : each.key
  server_id = azurerm_mssql_server.main.id

  sku_name     = coalesce(each.value.sku_name, var.single_databases_sku_name)
  license_type = each.value.license_type

  collation      = coalesce(each.value.collation, var.databases_collation)
  max_size_gb    = can(regex("Secondary|OnlineSecondary", each.value.create_mode)) ? null : each.value.max_size_gb
  zone_redundant = can(regex("^DW", var.single_databases_sku_name)) && var.databases_zone_redundant != null ? var.databases_zone_redundant : false

  min_capacity                = can(regex("^GP_S|HS", var.single_databases_sku_name)) ? each.value.min_capacity : null
  auto_pause_delay_in_minutes = can(regex("^GP_S", var.single_databases_sku_name)) ? each.value.auto_pause_delay_in_minutes : null

  read_scale         = can(regex("^P|BC|HS", var.single_databases_sku_name)) && each.value.read_scale != null ? each.value.read_scale : false
  read_replica_count = can(regex("^HS", var.single_databases_sku_name)) ? each.value.read_replica_count : null

  #https://docs.microsoft.com/en-us/dotnet/api/microsoft.azure.management.sql.models.database.createmode?view=azure-dotnet
  create_mode = can(regex("^DW", var.single_databases_sku_name)) ? try(local.datawarehouse_allowed_create_mode[each.value.create_mode], "Default") : try(local.standard_allowed_create_mode[each.value.create_mode], "Default")

  creation_source_database_id = can(regex("Copy|Secondary|PointInTimeRestore|Recovery|RestoreExternalBackup|Restore|RestoreExternalBackupSecondary", each.value.create_mode)) ? each.value.creation_source_database_id : null

  restore_point_in_time       = each.value.create_mode == "PointInTimeRestore" ? each.value.restore_point_in_time : null
  recover_database_id         = each.value.create_mode == "Recovery" ? each.value.recover_database_id : null
  restore_dropped_database_id = each.value.create_mode == "Restore" ? each.value.restore_dropped_database_id : null

  storage_account_type = each.value.storage_account_type

  dynamic "identity" {
    for_each = each.value.identity_ids != null ? length(each.value.identity_ids) > 0 ? ["UserAssigned"] : [] : []
    content {
      type         = "UserAssigned"
      identity_ids = each.value.identity_ids
    }
  }

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
      try(var.backup_retention.weekly_retention, ""),
      try(var.backup_retention.monthly_retention, ""),
      try(var.backup_retention.yearly_retention, ""),
      try(var.backup_retention.week_of_year, ""),
      "empty"
    ) == "empty" ? [] : ["enabled"]
    content {
      weekly_retention  = try(format("P%sW", var.backup_retention.weekly_retention), null)
      monthly_retention = try(format("P%sM", var.backup_retention.monthly_retention), null)
      yearly_retention  = try(format("P%sY", var.backup_retention.yearly_retention), null)
      week_of_year      = var.backup_retention.week_of_year
    }
  }

  tags = merge(local.default_tags, var.extra_tags, try(each.value.database_extra_tags, {}))
}

resource "azurerm_mssql_database" "elastic_pool_database" {
  for_each = try({ for db in var.databases : db.name => db if var.elastic_pool_enabled }, {})

  name      = var.use_caf_naming_for_databases ? data.azurecaf_name.sql_dbs[each.key].result : each.key
  server_id = azurerm_mssql_server.main.id

  sku_name        = "ElasticPool"
  license_type    = each.value.license_type
  elastic_pool_id = one(azurerm_mssql_elasticpool.main[*].id)

  collation      = coalesce(each.value.collation, var.databases_collation)
  max_size_gb    = can(regex("Secondary|OnlineSecondary", each.value.create_mode)) ? null : each.value.max_size_gb
  zone_redundant = can(regex("^DW", var.single_databases_sku_name)) && var.databases_zone_redundant != null ? var.databases_zone_redundant : false

  #https://docs.microsoft.com/en-us/dotnet/api/microsoft.azure.management.sql.models.database.createmode?view=azure-dotnet
  create_mode = try(local.standard_allowed_create_mode[each.value.create_mode], "Default")

  creation_source_database_id = can(regex("Copy|Secondary|PointInTimeRestore|Recovery|RestoreExternalBackup|Restore|RestoreExternalBackupSecondary", each.value.create_mode)) ? each.value.creation_source_database_id : null

  restore_point_in_time       = each.value.create_mode == "PointInTimeRestore" ? each.value.restore_point_in_time : null
  recover_database_id         = each.value.create_mode == "Recovery" ? each.value.recover_database_id : null
  restore_dropped_database_id = each.value.create_mode == "Restore" ? each.value.restore_dropped_database_id : null

  read_replica_count = startswith(local.elastic_pool_sku.name, "HS") ? each.value.read_replica_count : null

  storage_account_type = each.value.storage_account_type

  dynamic "identity" {
    for_each = each.value.identity_ids != null ? length(each.value.identity_ids) > 0 ? ["UserAssigned"] : [] : []
    content {
      type         = "UserAssigned"
      identity_ids = each.value.identity_ids
    }
  }

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

  dynamic "short_term_retention_policy" {
    for_each = startswith(local.elastic_pool_sku.name, "HS") ? [] : ["enabled"]
    content {
      retention_days           = var.point_in_time_restore_retention_days
      backup_interval_in_hours = var.point_in_time_backup_interval_in_hours
    }
  }

  dynamic "long_term_retention_policy" {
    for_each = coalesce(
      try(var.backup_retention.weekly_retention, ""),
      try(var.backup_retention.monthly_retention, ""),
      try(var.backup_retention.yearly_retention, ""),
      try(var.backup_retention.week_of_year, ""),
      "empty"
    ) == "empty" ? [] : ["enabled"]
    content {
      weekly_retention  = try(format("P%sW", var.backup_retention.weekly_retention), null)
      monthly_retention = try(format("P%sM", var.backup_retention.monthly_retention), null)
      yearly_retention  = try(format("P%sY", var.backup_retention.yearly_retention), null)
      week_of_year      = var.backup_retention.week_of_year
    }

  }

  tags = merge(local.default_tags, var.extra_tags, try(each.value.database_extra_tags, {}))
}
