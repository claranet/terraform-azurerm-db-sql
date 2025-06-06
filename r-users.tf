module "databases_users" {
  for_each = try({ for user in local.databases_users : format("%s-%s", user.username, user.database) => user }, {})

  source = "./modules/databases_users"

  depends_on = [
    azurerm_mssql_database.main
  ]

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  sql_server_hostname = azurerm_mssql_server.main.fully_qualified_domain_name

  database_name = each.value.database
  user_name     = each.value.username
  user_roles    = each.value.roles
}

module "custom_users" {
  for_each = try({ for custom_user in var.custom_users : format("%s-%s", custom_user.name, custom_user.database) => custom_user }, {})

  source = "./modules/databases_users"

  depends_on = [
    azurerm_mssql_database.main
  ]

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  sql_server_hostname = azurerm_mssql_server.main.fully_qualified_domain_name

  database_name = azurerm_mssql_database.main[each.value.database].name
  user_name     = each.value.name
  user_roles    = each.value.roles
}
