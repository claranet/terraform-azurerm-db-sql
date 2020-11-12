resource "random_password" "db_passwords" {
  for_each = var.create_databases_users ? toset(var.elasticpool_databases) : []
  special  = "false"
  length   = 32
}

resource "null_resource" "db_users" {
  for_each = var.create_databases_users ? toset(var.elasticpool_databases) : []

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

resource "random_password" "custom-users" {
  for_each = { for user_def in var.custom_users : format("%s-%s", user_def.name, user_def.database) => user_def }
  length   = 32
  special  = false
}

resource "null_resource" "custom-users" {
  depends_on = [azurerm_sql_database.db]
  for_each   = { for user_def in var.custom_users : format("%s-%s", user_def.name, user_def.database) => user_def }

  triggers = {
    user           = each.value.name
    password       = random_password.custom-users[each.key].result
    roles          = join(",", each.value.roles)
    database       = each.value.database
    server         = azurerm_sql_server.server.fully_qualified_domain_name
    admin_login    = var.administrator_login
    admin_password = var.administrator_password
  }

  provisioner "local-exec" {
    command = <<EOC
python3 -m pip install --upgrade pymssql==2.1.5;
${path.module}/scripts/mssql_users.py --debug \
                                              -s ${azurerm_sql_server.server.fully_qualified_domain_name} \
                                              -d ${each.value.database} \
                                              --admin-user ${var.administrator_login} \
                                              --admin-password '${var.administrator_password}' \
                                              --user ${each.value.name} \
                                              --password '${random_password.custom-users[each.key].result}' \
                                              --roles ${join(",", each.value.roles)}
EOC
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOC
${path.module}/scripts/mssql_users.py --debug \
                                              -s ${self.triggers.server} \
                                              -d ${self.triggers.database} \
                                              --admin-user ${self.triggers.admin_login} \
                                              --admin-password '${self.triggers.admin_password}' \
                                              --user ${self.triggers.user} \
                                              --delete
EOC
  }

}
