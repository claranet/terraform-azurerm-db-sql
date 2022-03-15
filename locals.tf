locals {
  name_prefix  = var.name_prefix != "" ? replace(var.name_prefix, "/[a-z0-9]$/", "$0-") : ""
  default_name = lower("${local.name_prefix}${var.stack}-${var.client_name}-${var.location_short}-${var.environment}")

  server_name = coalesce(var.server_custom_name, "${local.default_name}-sql")

  elastic_pool_name = coalesce(var.elastic_pool_custom_name, "${local.default_name}-pool")

  vcore_tiers                 = ["GeneralPurpose", "BusinessCritical"]
  elastic_pool_vcore_family   = "Gen5"
  elastic_pool_vcore_sku_name = var.sku != null ? format("%s_%s", var.sku.tier == "GeneralPurpose" ? "GP" : "BC", local.elastic_pool_vcore_family) : null
  elastic_pool_dtu_sku_name   = var.sku != null ? format("%sPool", var.sku.tier) : null
  elastic_pool_sku = var.sku != null ? {
    name     = contains(local.vcore_tiers, var.sku.tier) ? local.elastic_pool_vcore_sku_name : local.elastic_pool_dtu_sku_name
    capacity = var.sku.capacity
    tier     = var.sku.tier
    family   = contains(local.vcore_tiers, var.sku.tier) ? local.elastic_pool_vcore_family : null
  } : null

  databases_users = var.create_databases_users ? { for db in var.elasticpool_databases : db => format("%s_user", replace(db, "-", "_")) } : {}

  allowed_subnets = [
    for id in var.allowed_subnets_ids : {
      name      = split("/", id)[10]
      subnet_id = id
    }
  ]

  default_database_single = {
    collation      = "SQL_Latin1_General_CP1_CI_AS"
    read_scale     = false
    sku_name       = "Basic"
    zone_redundant = false
    threat_detection_policy = {
      state = "Disabled"
    }
    retention_days = 7
  }

  single_databases_configuration = [for db in var.single_databases_configuration : merge(local.default_database_single, { for k, v in db : k => v if v != null }) if var.enable_elasticpool == false]
}
