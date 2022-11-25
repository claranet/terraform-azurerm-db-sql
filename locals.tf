locals {
  vcore_tiers                 = ["GeneralPurpose", "BusinessCritical"]
  elastic_pool_vcore_family   = "Gen5"
  elastic_pool_vcore_sku_name = var.elastic_pool_sku != null ? format("%s_%s", var.elastic_pool_sku.tier == "GeneralPurpose" ? "GP" : "BC", local.elastic_pool_vcore_family) : null
  elastic_pool_dtu_sku_name   = var.elastic_pool_sku != null ? format("%sPool", var.elastic_pool_sku.tier) : null
  elastic_pool_sku = var.elastic_pool_sku != null ? {
    name     = contains(local.vcore_tiers, var.elastic_pool_sku.tier) ? local.elastic_pool_vcore_sku_name : local.elastic_pool_dtu_sku_name
    capacity = var.elastic_pool_sku.capacity
    tier     = var.elastic_pool_sku.tier
    family   = contains(local.vcore_tiers, var.elastic_pool_sku.tier) ? local.elastic_pool_vcore_family : null
  } : null

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
