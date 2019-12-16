module "logging" {
  source = "github.com/claranet/terraform-azurerm-diagnostic-settings.git?ref=multiple-resources"

  resources_count = var.enable_logging ? length(var.databases_names) : 0
  resource_ids    = azurerm_sql_database.db.*.id
  retention_days  = var.logs_storage_retention

  storage_account_id         = var.logs_storage_account_id
  log_analytics_workspace_id = var.logs_log_analytics_workspace_id
}
