resource "random_string" "db_passwords" {
  count = "${var.create_databases_users ? length(var.databases_names) : 0}"

  special = "false"
  length  = 32
}

resource "null_resource" "db_users" {
  count = "${var.create_databases_users ? length(var.databases_names) : 0}"

  provisioner "local-exec" {
    command = <<EOC
      Invoke-Sqlcmd -Query "CREATE LOGIN ${format("%s_user", element(var.databases_names, count.index))} WITH PASSWORD = '${element(random_string.db_passwords.*.result, count.index)}';" -ServerInstance ${azurerm_sql_server.server.fully_qualified_domain_name} -Username ${var.administrator_login} -Password ${var.administrator_password}
      Invoke-Sqlcmd -Query "CREATE USER ${format("%s_user", element(var.databases_names, count.index))} FOR LOGIN ${format("%s_user", element(var.databases_names, count.index))} WITH DEFAULT_SCHEMA = ${element(var.databases_names, count.index)};" -ServerInstance ${azurerm_sql_server.server.fully_qualified_domain_name} -Username ${var.administrator_login} -Password ${var.administrator_password} -Database ${element(var.databases_names, count.index)}
EOC

    interpreter = ["powershell", "-c"]
  }
}
