resource "random_password" "db_passwords" {
  for_each = { for user in local.databases_users : "${user.username}-${user.database}" => user }

  special          = true
  override_special = "#$%&-_+{}<>:"
  upper            = true
  lower            = true
  number           = true
  length           = 32
}

resource "mssql_login" "sql_login" {
  for_each   = { for user in local.databases_users : "${user.username}-${user.database}" => user }
  depends_on = [azurerm_mssql_database.db]

  server {
    host = azurerm_sql_server.server.fully_qualified_domain_name
    login {
      username = var.administrator_login
      password = var.administrator_password
    }
  }
  login_name = each.key
  password   = random_password.db_passwords[each.key].result
}

resource "mssql_user" "sql_user" {
  for_each   = { for user in local.databases_users : "${user.username}-${user.database}" => user }
  depends_on = [mssql_login.sql_login]

  server {
    host = azurerm_sql_server.server.fully_qualified_domain_name

    login {
      username = var.administrator_login
      password = var.administrator_password
    }
  }
  username   = each.key
  login_name = each.key
  database   = each.value.database
  roles      = each.value.roles
}
