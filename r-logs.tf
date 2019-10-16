module "logging" {
  source = "github.com/claranet/terraform-azurerm-diagnostic-settings.git?ref=multiple-resources"

  enabled        = var.enable_logging
  resource_ids   = azurerm_sql_database.db.*.id
  retention_days = var.logs_storage_retention

  storage_account_id         = var.logs_storage_account_id
  log_analytics_workspace_id = var.logs_log_analytics_workspace_id
}
