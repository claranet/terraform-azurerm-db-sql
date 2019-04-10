variable "client_name" {
  type = "string"
}

variable "environment" {
  type = "string"
}

variable "stack" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "location" {
  description = "Azure location for SQL Server."
  type        = "string"
}

variable "location_short" {
  description = "Short string for Azure location."
  type        = "string"
}

variable "name_prefix" {
  description = "Optional prefix for the generated name"
  type        = "string"
  default     = ""
}

variable "version" {
  description = "Versio of the SQL Server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). See https://www.terraform.io/docs/providers/azurerm/r/sql_server.html#version"
  type        = "string"
  default     = "12.0"
}

variable "extra_tags" {
  description = "Extra tags to add"
  type        = "map"
  default     = {}
}

variable "server_extra_tags" {
  description = "Extra tags to add on SQL Server"
  type        = "map"
  default     = {}
}

variable "elastic_pool_extra_tags" {
  description = "Extra tags to add on the SQL Elastic Pool"
  type        = "map"
  default     = {}
}

variable "databases_extra_tags" {
  description = "Extra tags to add on the SQL databases"
  type        = "map"
  default     = {}
}

variable "server_custom_name" {
  description = "Name of the SQL Server, generated if not set."
  type        = "string"
  default     = ""
}

variable "elastic_pool_custom_name" {
  description = "Name of the SQL Elastic Pool, generated if not set."
  type        = "string"
  default     = ""
}

variable "administrator_login" {
  description = "Administrator login for SQL Server"
  type        = "string"
}

variable "administrator_password" {
  description = "Administrator password for SQL Server"
  type        = "string"
}

variable "elastic_pool_max_size" {
  description = "Maximum size of the Elastic Pool in gigabytes"
  type        = "string"
}

variable "sku_tier" {
  description = "SKU tier for the Elastic Pool. Premium tier with zone redundancy is mandatory for high availability. Possible values are \"Basic\", \"Standard\", or \"Premium\"."
  type        = "string"
}

variable "sku_capacity" {
  description = "SKU capacity (eDTUs) for the Elastic Pool. See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-dtu-resource-limits-elastic-pools"
  type        = "string"
}

variable "zone_redundant" {
  description = "Whether or not the Elastic Pool is zone redundant, SKU tier must be Premium to use it. This is mandatory for high availability."
  type        = "string"
  default     = "false"
}

variable "database_min_dtu_capacity" {
  description = "The minimum capacity all databases are guaranteed in the Elastic Pool. Defaults to 0."
  type        = "string"
  default     = "0"
}

variable "database_max_dtu_capacity" {
  description = "The maximum capacity any one database can consume in the Elastic Pool. Default to the max Elastic Pool capacity."
  type        = "string"
  default     = ""
}

variable "databases_names" {
  description = "Names of the databases to create for this server"
  type        = "list"
}

variable "databases_collation" {
  description = "SQL Collation for the databases"
  default     = "SQL_LATIN1_GENERAL_CP1_CI_AS"
}

variable "logs_retention" {
  description = "Retention in days for databases logs on Storage Account"
  type        = "string"
  default     = "30"
}

variable "logs_storage_account_name" {
  description = "Storage Account name for databases logs"
  type        = "string"
}

variable "logs_storage_account_rg" {
  description = "Storage Account Resource Group name for databases logs"
  type        = "string"
}
