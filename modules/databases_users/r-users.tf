resource "random_password" "custom_user_password" {

  special          = true
  override_special = "#$%&-_+{}<>:"
  upper            = true
  lower            = true
  numeric          = true
  length           = 32
}

resource "mssql_login" "custom_sql_login" {

  server {
    host = var.sql_server_hostname
    login {
      username = var.administrator_login
      password = var.administrator_password
    }
  }
  login_name = var.user_name
  password   = random_password.custom_user_password.result
}

resource "mssql_user" "custom_sql_user" {
  depends_on = [mssql_login.custom_sql_login]

  server {
    host = var.sql_server_hostname

    login {
      username = var.administrator_login
      password = var.administrator_password
    }
  }
  username   = var.user_name
  login_name = var.user_name
  database   = var.database_name
  roles      = var.user_roles
}
