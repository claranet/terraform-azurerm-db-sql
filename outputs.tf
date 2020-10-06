output "sql_server_id" {
  description = "Id of the SQL Server"
  value       = azurerm_sql_server.server.id
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_sql_server.server.fully_qualified_domain_name
}

output "sql_elastic_pool_id" {
  description = "Id of the SQL Elastic Pool"
  value       = azurerm_mssql_elasticpool.elastic_pool.id
}

output "sql_databases_id" {
  description = "Map of the SQL Databases IDs"
  value       = { for db in azurerm_sql_database.db : db.name => db.id }
}

output "sql_databases_creation_date" {
  description = "Map of the SQL Databases creation dates"
  value       = { for db in azurerm_sql_database.db : db.name => db.creation_date }
}

output "sql_databases_default_secondary_location" {
  description = "Map of the SQL Databases default secondary location"
  value       = { for db in azurerm_sql_database.db : db.name => db.default_secondary_location }
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
  sensitive   = true
}

output "databases_users_passwords" {
  description = "Map of the SQL Databases dedicated passwords"
  value       = { for db in azurerm_sql_database.db : db.name => random_password.db_passwords[db.name].result }
  sensitive   = true
}
