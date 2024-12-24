output "resource" {
  description = "SQL Server resource object."
  value       = azurerm_mssql_server.main
  sensitive   = true
}

output "administrator_login" {
  description = "SQL Administrator login."
  value       = var.administrator_login
  sensitive   = true
}

output "administrator_password" {
  description = "SQL Administrator password."
  value       = var.administrator_password
  sensitive   = true
}

output "elastic_pool_resource" {
  description = "SQL Elastic Pool resource."
  value       = one(azurerm_mssql_elasticpool.main[*])
}

output "databases_resource" {
  description = "SQL Databases resource list."
  value       = var.elastic_pool_enabled ? azurerm_mssql_database.elastic_pool_database : azurerm_mssql_database.single_database
}

output "elastic_pool_id" {
  description = "ID of the SQL Elastic Pool."
  value       = one(azurerm_mssql_elasticpool.main[*].id)
}

output "databases_id" {
  description = "Map of the SQL Databases names => IDs."
  value       = var.elastic_pool_enabled ? { for db in azurerm_mssql_database.elastic_pool_database : db.name => db.id } : { for db in azurerm_mssql_database.single_database : db.name => db.id }
}

output "default_administrator_databases_connection_strings" {
  description = "Map of the SQL Databases with administrator credentials connection strings"
  value = var.elastic_pool_enabled ? {
    for db in azurerm_mssql_database.elastic_pool_database : db.name => formatlist(
      "Server=tcp:%s;Database=%s;User ID=%s;Password=%s;Encrypt=true;",
      azurerm_mssql_server.main.fully_qualified_domain_name,
      db.name,
      var.administrator_login,
      var.administrator_password
    )
    } : {
    for db in azurerm_mssql_database.single_database : db.name => formatlist(
      "Server=tcp:%s;Database=%s;User ID=%s;Password=%s;Encrypt=true;",
      azurerm_mssql_server.main.fully_qualified_domain_name,
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
    db_user.database => { "user_name" = db_user.username, "password" = module.databases_users[format("%s-%s", db_user.username, db_user.database)].database_user_password }
  }
  sensitive = true
}

output "custom_databases_users" {
  description = "Map of the custom SQL Databases users"
  value = {
    for custom_user in var.custom_users :
    custom_user.database => { "user_name" = custom_user.name, "password" = module.custom_users[format("%s-%s", custom_user.name, custom_user.database)].database_user_password }...
  }
  sensitive = true
}

output "custom_databases_users_roles" {
  description = "Map of the custom SQL Databases users roles"
  value = {
    for custom_user in var.custom_users :
    join("-", [custom_user.name, custom_user.database]) => module.custom_users[join("-", [custom_user.name, custom_user.database])].database_user_roles
  }
}

output "identity_principal_id" {
  description = "SQL Server system identity principal ID."
  value       = try(azurerm_mssql_server.main.identity[0], null)
}

output "security_alert_policy_id" {
  description = "ID of the MS SQL Server Security Alert Policy"
  value       = one(azurerm_mssql_server_security_alert_policy.main[*].id)
}

output "vulnerability_assessment_id" {
  description = "ID of the MS SQL Server Vulnerability Assessment."
  value       = one(azurerm_mssql_server_vulnerability_assessment.main[*].id)
}

output "terraform_module" {
  description = "Information about this Terraform module."
  value = {
    name       = "db-sql"
    provider   = "azurerm"
    maintainer = "claranet"
  }
}
