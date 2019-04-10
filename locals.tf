locals {
  default_tags = {
    env   = "${var.environment}"
    stack = "${var.stack}"
  }

  name_prefix = "${var.name_prefix != "" ? "${var.name_prefix}-" : ""}"

  server_name       = "${coalesce(var.server_custom_name, "${local.name_prefix}${var.stack}-${var.client_name}-${var.location_short}-${var.environment}-sql")}"
  elastic_pool_name = "${coalesce(var.elastic_pool_custom_name, "${local.name_prefix}${var.stack}-${var.client_name}-${var.location_short}-${var.environment}-pool")}"

  elastic_pool_sku = {
    name     = "${lookup(var.sku, "tier")}Pool"
    capacity = "${lookup(var.sku, "capacity")}"
    tier     = "${lookup(var.sku, "tier")}"
  }
}
