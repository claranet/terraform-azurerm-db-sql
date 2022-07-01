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

output "sql_elastic_pool_id" {
  description = "ID of the SQL Elastic Pool"
  value       = var.enable_elasticpool ? azurerm_mssql_elasticpool.elastic_pool[0].id : null
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
  value       = var.create_databases_users ? { for db in azurerm_sql_database.db : db.name => random_password.db_passwords[db.name].result } : {}
  sensitive   = true
}

output "custom_users_passwords" {
  description = "Map of the custom users passwords"
  value       = length(var.custom_users) == 0 ? {} : { for user in var.custom_users : format("%s-%s", user.name, user.database) => random_password.custom_users[format("%s-%s", user.name, user.database)].result }
  sensitive   = true
}

output "databases_single_ids" {
  description = "MSSQL Database single IDs map"
  value       = { for db in azurerm_mssql_database.single_database : db.name => db.id }
}
