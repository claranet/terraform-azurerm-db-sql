data "azurerm_subscription" "current" {}

resource "null_resource" "backup" {
  count = length(var.databases_names)

  provisioner "local-exec" {
    command = <<EOC
      $accessToken = az account get-access-token -s ${data.azurerm_subscription.current.subscription_id} --query "accessToken" -o tsv
      $accountId = az account show -s ${data.azurerm_subscription.current.subscription_id} --query "user.name" -o tsv
      Connect-AzAccount -AccessToken $accessToken -AccountId $accountId -Force
      Get-AzSubscription -SubscriptionId ${data.azurerm_subscription.current.subscription_id} | Set-AzContext -Name "terraform-${data.azurerm_subscription.current.subscription_id}" -Force

      Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName ${var.resource_group_name} -ServerName ${azurerm_sql_server.server.name} -DatabaseName ${element(var.databases_names, count.index)} -RetentionDays ${var.backup_retention}
EOC

    interpreter = ["pwsh", "-c"]
  }

  triggers = {
    database  = element(var.databases_names, count.index)
    retention = var.backup_retention
  }

  depends_on = [azurerm_sql_database.db]
}
