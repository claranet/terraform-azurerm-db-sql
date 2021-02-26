locals {
  default_tags = {
    env   = var.environment
    stack = var.stack
  }

  name_prefix  = var.name_prefix != "" ? replace(var.name_prefix, "/[a-z0-9]$/", "$0-") : ""
  default_name = lower("${local.name_prefix}${var.stack}-${var.client_name}-${var.location_short}-${var.environment}")

  server_name = coalesce(var.server_custom_name, "${local.default_name}-sql")

  elastic_pool_name = coalesce(var.elastic_pool_custom_name, "${local.default_name}-pool")

  vcore_tiers                 = ["GeneralPurpose", "BusinessCritical"]
  elastic_pool_vcore_family   = "Gen5"
  elastic_pool_vcore_sku_name = format("%s_%s", var.sku.tier == "GeneralPurpose" ? "GP" : "BC", local.elastic_pool_vcore_family)
  elastic_pool_dtu_sku_name   = format("%sPool", var.sku.tier)
  elastic_pool_sku = {
    name     = contains(local.vcore_tiers, var.sku.tier) ? local.elastic_pool_vcore_sku_name : local.elastic_pool_dtu_sku_name
    capacity = var.sku.capacity
    tier     = var.sku.tier
    family   = contains(local.vcore_tiers, var.sku.tier) ? local.elastic_pool_vcore_family : null
  }

  databases_users = var.create_databases_users ? { for db in var.databases_names : db => format("%s_user", replace(db, "-", "_")) } : {}

  allowed_subnets = [
    for id in var.allowed_subnets_ids : {
      name      = split("/", id)[10]
      subnet_id = id
    }
  ]
}
