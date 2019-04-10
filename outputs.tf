output "sql_server_id" {
  description = "Id of the SQL Server"
  value       = "${azurerm_sql_server.server.id}"
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = "${azurerm_sql_server.server.fully_qualified_domain_name}"
}

output "sql_elastic_pool_id" {
  description = "Id of the SQL Elastic Pool"
  value       = "${azurerm_mssql_elasticpool.elastic_pool.id}"
}

output "sql_databases_id" {
  description = "Id of the SQL Databases"
  value       = "${azurerm_sql_database.db.*.id}"
}

output "sql_databases_creation_date" {
  description = "Creation date of the SQL Databases"
  value       = "${azurerm_sql_database.db.*.creation_date}"
}

output "sql_databases_default_secondary_location" {
  description = "The default secondary location of the SQL Databases"
  value       = "${azurerm_sql_database.db.*.default_secondary_location}"
}
