resource "random_password" "main" {
  special          = true
  override_special = "#$%&-_+{}<>:"
  upper            = true
  lower            = true
  numeric          = true
  length           = 32
}

resource "mssql_login" "main" {
  server {
    host = var.sql_server_hostname
    login {
      username = var.administrator_login
      password = var.administrator_password
    }
  }
  login_name = var.user_name
  password   = random_password.main.result
}

resource "mssql_user" "main" {
  depends_on = [mssql_login.main]

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

moved {
  from = random_password.custom_user_password
  to   = random_password.main
}
moved {
  from = mssql_login.custom_sql_login
  to   = mssql_login.main
}
moved {
  from = mssql_user.custom_sql_user
  to   = mssql_user.main
}
