data "azurerm_subscription" "current" {}

resource "null_resource" "backup" {
  count = length(var.databases_names)

  provisioner "local-exec" {
    command = <<EOC
      $accessToken = az account get-access-token -s ${data.azurerm_subscription.current.subscription_id} --query "accessToken" -o tsv
      $accountId = az account show -s ${data.azurerm_subscription.current.subscription_id} --query "user.name" -o tsv
      Disconnect-AzAccount
      Connect-AzAccount -AccessToken $accessToken -AccountId $accountId -Force
      Get-AzSubscription -SubscriptionId ${data.azurerm_subscription.current.subscription_id} | Set-AzContext -Name "terraform-${data.azurerm_subscription.current.subscription_id}" -Force

      Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName ${var.resource_group_name} -ServerName ${azurerm_sql_server.server.name} -DatabaseName ${element(var.databases_names, count.index)} -RetentionDays ${var.daily_backup_retention}
EOC

    interpreter = ["pwsh", "-c"]
  }

  triggers = {
    database  = element(var.databases_names, count.index)
    retention = var.daily_backup_retention
  }

  depends_on = [azurerm_sql_database.db]
}

resource "null_resource" "ltr_backup" {
  count = length(var.databases_names)

  provisioner "local-exec" {
    command = <<EOC
      $accessToken = az account get-access-token -s ${data.azurerm_subscription.current.subscription_id} --query "accessToken" -o tsv
      $accountId = az account show -s ${data.azurerm_subscription.current.subscription_id} --query "user.name" -o tsv
      Connect-AzAccount -AccessToken $accessToken -AccountId $accountId -Force
      Get-AzSubscription -SubscriptionId ${data.azurerm_subscription.current.subscription_id} | Set-AzContext -Name "terraform-${data.azurerm_subscription.current.subscription_id}" -Force

      # Since this command is very long and can take around 1 hour, we do it asynchronously and wait a little to be sure it's started
      Start-Job -ScriptBlock { Set-AzSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName ${var.resource_group_name} -ServerName ${azurerm_sql_server.server.name} -DatabaseName ${element(var.databases_names, count.index)} -WeeklyRetention P${var.weekly_backup_retention}W -MonthlyRetention P${var.monthly_backup_retention}M -YearlyRetention P${var.yearly_backup_retention}Y -WeekOfYear ${var.yearly_backup_time} }
      Start-Sleep 20
EOC

    interpreter = ["pwsh", "-c"]
  }

  triggers = {
    database           = element(var.databases_names, count.index)
    weekly_retention   = var.weekly_backup_retention
    monthly_retention  = var.monthly_backup_retention
    yearly_retention   = var.yearly_backup_retention
    yearly_backup_time = var.yearly_backup_time
  }

  depends_on = [azurerm_sql_database.db]
}
