locals {
  vcore_tiers = {
    GeneralPurpose   = "GP"
    BusinessCritical = "BC"
    Hyperscale       = "HS"
  }
  elastic_pool_vcore_family   = try(var.elastic_pool_sku.family, "Gen5")
  elastic_pool_vcore_sku_name = var.elastic_pool_sku != null ? format("%s_%s", local.vcore_tiers[var.elastic_pool_sku.tier], local.elastic_pool_vcore_family) : null
  elastic_pool_dtu_sku_name   = var.elastic_pool_sku != null ? format("%sPool", var.elastic_pool_sku.tier) : null
  elastic_pool_sku = var.elastic_pool_sku != null ? {
    name     = contains(keys(local.vcore_tiers), var.elastic_pool_sku.tier) ? local.elastic_pool_vcore_sku_name : local.elastic_pool_dtu_sku_name
    capacity = var.elastic_pool_sku.capacity
    tier     = var.elastic_pool_sku.tier
    family   = contains(keys(local.vcore_tiers), var.elastic_pool_sku.tier) ? local.elastic_pool_vcore_family : null
  } : null

  # Effective SKU of each database: the elastic pool tier for pooled databases, the database or module SKU otherwise
  databases_sku = {
    for db in var.databases : db.name => lower(var.elastic_pool_enabled ? try(var.elastic_pool_sku.tier, "") : coalesce(db.sku_name, var.single_databases_sku_name))
  }

  # Basic and Free tiers cap the point-in-time restore retention at 7 days
  databases_pitr_retention_days = {
    for name, sku in local.databases_sku : name => coalesce(var.point_in_time_restore_retention_days, contains(["basic", "free"], sku) ? 7 : 30)
  }

  # Data Warehouse and Free SKUs do not support long term retention: the provider skips it and reads it back empty
  databases_ltr_supported = {
    for name, sku in local.databases_sku : name => !startswith(sku, "dw") && sku != "free"
  }

  allowed_subnets = [
    for id in var.allowed_subnets_ids : {
      name      = split("/", id)[10]
      subnet_id = id
    }
  ]

  databases_users = var.create_databases_users ? [
    for db in var.databases : {
      username = format("%s_user", replace(db.name, "-", "_"))
      database = db.name
      roles    = ["db_owner"]
    }
  ] : []

  standard_allowed_create_mode = {
    "a" = "Default"
    "b" = "Copy"
    "c" = "Secondary"
    "d" = "PointInTimeRestore"
    "e" = "Restore"
    "f" = "Recovery"
    "g" = "RestoreExternalBackup"
    "h" = "RestoreExternalBackup"
    "i" = "RestoreLongTermRetentionBackup"
    "j" = "OnlineSecondary"
  }

  datawarehouse_allowed_create_mode = {
    "a" = "Default"
    "b" = "PointInTimeRestore"
    "c" = "Restore"
    "d" = "Recovery"
    "e" = "RestoreExternalBackup"
    "f" = "RestoreExternalBackup"
    "g" = "OnlineSecondary"
  }
}
