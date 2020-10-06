resource "random_password" "db_passwords" {
  for_each = var.create_databases_users ? toset(var.databases_names) : toset([])

  special = "false"
  length  = 32
}

resource "null_resource" "db_users" {
  for_each = var.create_databases_users ? toset(var.databases_names) : toset([])

  depends_on = [azurerm_sql_database.db]

  provisioner "local-exec" {
    command = <<EOC
      Invoke-Sqlcmd -Query "`
        IF NOT EXISTS `
            (SELECT name `
             FROM  master.sys.sql_logins `
             WHERE name = '${local.databases_users[each.key]}') `
        BEGIN `
            CREATE LOGIN ${local.databases_users[each.key]} WITH PASSWORD = '${random_password.db_passwords[each.key].result}';`
        END `
      " -ServerInstance ${azurerm_sql_server.server.fully_qualified_domain_name} -Username ${var.administrator_login} -Password '${var.administrator_password}'

      Invoke-Sqlcmd -Query "`
        IF NOT EXISTS `
            (SELECT * FROM sys.database_principals `
             WHERE name='${local.databases_users[each.key]}') `
        BEGIN `
            CREATE USER ${local.databases_users[each.value]} FOR LOGIN ${local.databases_users[each.key]} WITH DEFAULT_SCHEMA = dbo; `
            ALTER ROLE db_owner ADD MEMBER ${local.databases_users[each.key]}; `
        END `
      " -ServerInstance ${azurerm_sql_server.server.fully_qualified_domain_name} -Username ${var.administrator_login} -Password '${var.administrator_password}' -Database ${each.key}
EOC

    interpreter = ["pwsh", "-c"]
  }
}
