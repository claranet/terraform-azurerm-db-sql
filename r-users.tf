resource "random_string" "db_passwords" {
  count = var.create_databases_users ? length(var.databases_names) : 0

  special = "false"
  length  = 32
}

resource "null_resource" "db_users" {
  count = var.create_databases_users ? length(var.databases_names) : 0

  depends_on = [azurerm_sql_database.db]

  provisioner "local-exec" {
    command = <<EOC
      Invoke-Sqlcmd -Query "`
        IF NOT EXISTS `
            (SELECT name `
             FROM  master.sys.sql_logins `
             WHERE name = '${format("%s_user", replace(element(var.databases_names, count.index), "-", "_"))}') `
        BEGIN `
            CREATE LOGIN ${format("%s_user", replace(element(var.databases_names, count.index), "-", "_"))} WITH PASSWORD = '${element(random_string.db_passwords.*.result, count.index)}';`
        END `
      " -ServerInstance ${azurerm_sql_server.server.fully_qualified_domain_name} -Username ${var.administrator_login} -Password ${var.administrator_password}

      Invoke-Sqlcmd -Query "`
        IF NOT EXISTS `
            (SELECT * FROM sys.database_principals `
             WHERE name='${format("%s_user", replace(element(var.databases_names, count.index), "-", "_"))}') `
        BEGIN `
            CREATE USER ${format("%s_user", replace(element(var.databases_names, count.index), "-", "_"))} FOR LOGIN ${format("%s_user", replace(element(var.databases_names, count.index), "-", "_"))} WITH DEFAULT_SCHEMA = ${element(var.databases_names, count.index)}; `
            ALTER ROLE db_owner ADD MEMBER ${format("%s_user", replace(element(var.databases_names, count.index), "-", "_"))}; `
        END `
      " -ServerInstance ${azurerm_sql_server.server.fully_qualified_domain_name} -Username ${var.administrator_login} -Password ${var.administrator_password} -Database ${element(var.databases_names, count.index)}
EOC

    interpreter = ["pwsh", "-c"]
  }

  triggers = {
    database = element(var.databases_names, count.index)
  }
}
