output "sql_server" {
  description = "SQL Server"
  value       = azurerm_sql_server.server
}

output "sql_elastic_pool" {
  description = "SQL Elastic Pool"
  value       = azurerm_mssql_elasticpool.elastic_pool
}

output "sql_databases" {
  description = "SQL Databases"
  value       = azurerm_sql_database.db
}

output "default_administrator_databases_connection_strings" {
  description = "Map of the SQL Databases with administrator credentials connection strings"
  value = {
    for db in azurerm_sql_database.db : db.name => formatlist(
      "Server=tcp:%s;Database=%s;User ID=%s;Password=%s;Encrypt=true;",
      azurerm_sql_server.server.fully_qualified_domain_name,
      db.name,
      var.administrator_login,
      var.administrator_password
    )
  }
  sensitive = true
}

output "databases_users" {
  description = "Map of the SQL Databases dedicated usernames"
  value       = local.databases_users
}

output "databases_users_passwords" {
  description = "Map of the SQL Databases dedicated passwords"
  value       = { for db in azurerm_sql_database.db : db.name => random_password.db_passwords[db.name].result }
  sensitive   = true
}
