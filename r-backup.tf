data "azurerm_subscription" "current" {}

resource "null_resource" "backup" {
  for_each = toset(var.enable_elasticpool ? var.elasticpool_databases : [])

  provisioner "local-exec" {
    command = <<EOC
      $accessToken = az account get-access-token -s ${data.azurerm_subscription.current.subscription_id} --query "accessToken" -o tsv 2>/dev/null
      $accountId = az account show -s ${data.azurerm_subscription.current.subscription_id} --query "user.name" -o tsv 2>/dev/null
      Disconnect-AzAccount 2>/dev/null
      Connect-AzAccount -AccessToken $accessToken -AccountId $accountId -Force 2>/dev/null
      Get-AzSubscription -SubscriptionId ${data.azurerm_subscription.current.subscription_id} | Set-AzContext -Name "terraform-${data.azurerm_subscription.current.subscription_id}" -Force 2>/dev/null

      Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName ${var.resource_group_name} -ServerName ${azurerm_sql_server.server.name} -DatabaseName ${each.key} -RetentionDays ${var.daily_backup_retention}
EOC

    interpreter = ["pwsh", "-c"]
  }

  triggers = {
    retention = var.daily_backup_retention
  }

  depends_on = [azurerm_sql_database.db]
}

resource "null_resource" "ltr_backup" {
  for_each = var.enable_elasticpool ? toset(var.elasticpool_databases) : toset([for db in var.single_databases_configuration : db.name if db.auto_pause_delay_in_minutes != -1])

  provisioner "local-exec" {
    command = <<EOC
      $accessToken = az account get-access-token -s ${data.azurerm_subscription.current.subscription_id} --query "accessToken" -o tsv 2>/dev/null
      $accountId = az account show -s ${data.azurerm_subscription.current.subscription_id} --query "user.name" -o tsv 2>/dev/null
      Disconnect-AzAccount 2>/dev/null
      Connect-AzAccount -AccessToken $accessToken -AccountId $accountId -Force 2>/dev/null
      Get-AzSubscription -SubscriptionId ${data.azurerm_subscription.current.subscription_id} | Set-AzContext -Name "terraform-${data.azurerm_subscription.current.subscription_id}" -Force

      # Since this command is very long and can take around 1 hour, we do it asynchronously and wait a little to be sure it's started
      Start-Job -ScriptBlock { Set-AzSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName ${var.resource_group_name} -ServerName ${azurerm_sql_server.server.name} -DatabaseName ${each.value} -WeeklyRetention P${var.weekly_backup_retention}W -MonthlyRetention P${var.monthly_backup_retention}M -YearlyRetention P${var.yearly_backup_retention}Y -WeekOfYear ${var.yearly_backup_time} }
      Start-Sleep 20
EOC

    interpreter = ["pwsh", "-c"]
  }

  triggers = {
    weekly_retention   = var.weekly_backup_retention
    monthly_retention  = var.monthly_backup_retention
    yearly_retention   = var.yearly_backup_retention
    yearly_backup_time = var.yearly_backup_time
  }

  depends_on = [azurerm_sql_database.db, azurerm_mssql_database.single_database]
}
