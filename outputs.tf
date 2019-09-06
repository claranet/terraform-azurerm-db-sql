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
  description = "Id of the SQL Databases"
  value       = azurerm_sql_database.db.*.id
}

output "sql_databases_creation_date" {
  description = "Creation date of the SQL Databases"
  value       = azurerm_sql_database.db.*.creation_date
}

output "sql_databases_default_secondary_location" {
  description = "The default secondary location of the SQL Databases"
  value       = azurerm_sql_database.db.*.default_secondary_location
}

output "default_administrator_databases_connection_strings" {
  description = "Connection strings of the SQL Databases with administrator credentials"
  value = formatlist(
    "Server=tcp:%s;Database=%s;User ID=%s;Password=%s;Encrypt=true;",
    azurerm_sql_server.server.fully_qualified_domain_name,
    azurerm_sql_database.db.*.name,
    var.administrator_login,
    var.administrator_password,
  )
  sensitive = true
}

output "databases_users" {
  description = "List of usernames of created users corresponding to input databases names."
  value       = formatlist("%s_user", var.databases_names)
  sensitive   = true
}

output "databases_users_passwords" {
  description = "List of passwords of created users corresponding to input databases names."
  value       = random_string.db_passwords.*.result
  sensitive   = true
}
