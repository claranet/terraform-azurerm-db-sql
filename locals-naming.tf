locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  server_name       = coalesce(var.server_custom_name, data.azurecaf_name.sql.result)
  elastic_pool_name = coalesce(var.elastic_pool_custom_name, data.azurecaf_name.sql_pool.result)
}
