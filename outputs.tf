output "sql_administrator_login" {
  description = "SQL Administrator login"
  value       = var.administrator_login
  sensitive   = true
}

output "sql_administrator_password" {
  description = "SQL Administrator password"
  value       = var.administrator_password
  sensitive   = true
}

output "sql_server" {
  description = "SQL Server FQDN"
  value       = azurerm_sql_server.server.fully_qualified_domain_name
}

output "sql_server_id" {
  description = "SQL Server ID"
  value       = azurerm_sql_server.server.id
}

output "sql_databases" {
  description = "SQL Databases"
  value       = azurerm_mssql_database.db
}

output "sql_elastic_pool_id" {
  description = "ID of the SQL Elastic Pool"
  value       = var.enable_elasticpool ? azurerm_mssql_elasticpool.elastic_pool[0].id : null
}

output "sql_databases_id" {
  description = "Map of the SQL Databases IDs"
  value       = { for db in azurerm_mssql_database.db : db.name => db.id }
}

output "default_administrator_databases_connection_strings" {
  description = "Map of the SQL Databases with administrator credentials connection strings"
  value = {
    for db in azurerm_mssql_database.db : db.name => formatlist(
      "Server=tcp:%s;Database=%s;User ID=%s;Password=%s;Encrypt=true;",
      azurerm_sql_server.server.fully_qualified_domain_name,
      db.name,
      var.administrator_login,
      var.administrator_password
    )
  }
  sensitive = true
}

output "default_databases_users" {
  description = "Map of the SQL Databases dedicated users"
  value = {
    for db_user in local.databases_users :
    "${db_user.username}-${db_user.database}" => db_user.username
  }
}

output "default_databases_users_passwords" {
  description = "Map of the SQL Databases dedicated passwords"
  value = {
    for db_user in local.databases_users :
    "${db_user.username}-${db_user.database}" => random_password.db_passwords["${db_user.username}-${db_user.database}"].result
  }
  sensitive = true
}

output "custom_databases_users" {
  description = "Map of the custom SQL Databases users"
  value = {
    for custom_user in var.custom_users :
    join("-", [custom_user.name, custom_user.database]) => module.custom_users[join("-", [custom_user.name, custom_user.database])].custom_user_name
  }
}

output "custom_databases_users_passwords" {
  description = "Map of the custom SQL Databases users passwords"
  value = {
    for custom_user in var.custom_users :
    join("-", [custom_user.name, custom_user.database]) => module.custom_users[join("-", [custom_user.name, custom_user.database])].custom_user_password
  }
  sensitive = true
}

output "custom_databases_users_roles" {
  description = "Map of the custom SQL Databases users roles"
  value = {
    for custom_user in var.custom_users :
    join("-", [custom_user.name, custom_user.database]) => module.custom_users[join("-", [custom_user.name, custom_user.database])].custom_user_roles
  }
}
