module "custom_users" {
  for_each = { for custom_user in var.custom_users : join("-", [custom_user.name, custom_user.database]) => custom_user }
  source   = "./modules/custom_users"

  database_name = azurerm_mssql_database.db[lookup(each.value, "database")].name
  user_name     = lookup(each.value, "name")
  user_roles    = lookup(each.value, "roles")

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password
  sql_server_hostname    = azurerm_sql_server.server.fully_qualified_domain_name

}
