# This resource represents both single databases and elastic pool databases
# The configuration is dynamically adjusted based on whether elastic_pool_enabled is true or false
resource "azurerm_mssql_database" "main" {
  # Include all databases in a single resource with a unified for_each
  for_each = try({ for db in var.databases : db.name => db }, {})

  # Common parameters for both single and elastic pool databases
  name      = var.use_caf_naming_for_databases ? data.azurecaf_name.sql_dbs[each.key].result : each.key
  server_id = azurerm_mssql_server.main.id

  # SKU name is conditionally set based on elastic pool status
  # For elastic pool databases: "ElasticPool"
  # For single databases: Use the provided SKU name or default
  sku_name     = var.elastic_pool_enabled ? "ElasticPool" : coalesce(each.value.sku_name, var.single_databases_sku_name)
  license_type = each.value.license_type

  # Elastic pool ID is only set for elastic pool databases
  elastic_pool_id = var.elastic_pool_enabled ? one(azurerm_mssql_elasticpool.main[*].id) : null

  # Common database configuration parameters
  collation      = coalesce(each.value.collation, var.databases_collation)
  max_size_gb    = can(regex("Secondary|OnlineSecondary", each.value.create_mode)) ? null : each.value.max_size_gb
  zone_redundant = can(regex("^DW", var.single_databases_sku_name)) && var.databases_zone_redundant != null ? var.databases_zone_redundant : false

  # Serverless configuration parameters - only applicable for single databases with specific SKUs
  min_capacity = !var.elastic_pool_enabled && can(regex("^GP_S|HS", var.single_databases_sku_name)) ? each.value.min_capacity : null

  auto_pause_delay_in_minutes = !var.elastic_pool_enabled && can(regex("^GP_S", var.single_databases_sku_name)) ? each.value.auto_pause_delay_in_minutes : null

  # Read scale configuration - only applicable for single databases with specific SKUs
  read_scale = !var.elastic_pool_enabled && can(regex("^P|BC|HS", var.single_databases_sku_name)) && each.value.read_scale != null ? each.value.read_scale : false

  # Read replica count - different conditions for single vs elastic pool databases
  read_replica_count = (
    var.elastic_pool_enabled ?
    (startswith(try(local.elastic_pool_sku.name, ""), "HS") ? each.value.read_replica_count : null) :
    (can(regex("^HS", var.single_databases_sku_name)) ? each.value.read_replica_count : null)
  )

  # Create mode - different logic for single databases with data warehouse SKUs
  # https://docs.microsoft.com/en-us/dotnet/api/microsoft.azure.management.sql.models.database.createmode?view=azure-dotnet
  create_mode = !var.elastic_pool_enabled && can(regex("^DW", var.single_databases_sku_name)) ? try(local.datawarehouse_allowed_create_mode[each.value.create_mode], "Default") : try(local.standard_allowed_create_mode[each.value.create_mode], "Default")

  # Common restore and recovery parameters
  creation_source_database_id = can(regex("Copy|Secondary|PointInTimeRestore|Recovery|RestoreExternalBackup|Restore|RestoreExternalBackupSecondary", each.value.create_mode)) ? each.value.creation_source_database_id : null

  restore_point_in_time       = each.value.create_mode == "PointInTimeRestore" ? each.value.restore_point_in_time : null
  recover_database_id         = each.value.create_mode == "Recovery" ? each.value.recover_database_id : null
  restore_dropped_database_id = each.value.create_mode == "Restore" ? each.value.restore_dropped_database_id : null

  # Storage configuration
  storage_account_type = each.value.storage_account_type

  dynamic "identity" {
    for_each = length(each.value.identity_ids) > 0 ? ["UserAssigned"] : []
    content {
      type         = "UserAssigned"
      identity_ids = each.value.identity_ids
    }
  }

  # Threat detection policy - same for both types
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

  # Short-term retention policy - different implementation for elastic pool vs single databases
  # For elastic pool databases: Use dynamic block with condition
  # For single databases: Always include the block
  dynamic "short_term_retention_policy" {
    # For elastic pool databases, exclude the block for HS SKUs
    # For single databases, always include the block
    for_each = var.elastic_pool_enabled && try(startswith(local.elastic_pool_sku.name, "HS"), false) ? [] : ["enabled"]
    content {
      retention_days = var.point_in_time_restore_retention_days
      # backup_interval_in_hours is only supported for elastic pool databases
      backup_interval_in_hours = var.elastic_pool_enabled ? var.point_in_time_backup_interval_in_hours : null
    }
  }

  # Long-term retention policy - same for both types
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

  # Tags - same for both types
  tags = merge(local.default_tags, var.extra_tags, try(each.value.database_extra_tags, {}))
}

moved {
  from = azurerm_mssql_database.single_database
  to   = azurerm_mssql_database.main
}
