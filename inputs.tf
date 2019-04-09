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

variable "database_extra_tags" {
  description = "Extra tags to add on the SQL database"
  type        = "map"
  default     = {}
}

variable "custom_name" {
  description = "Name of the SQL Server, generated if not set."
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

variable "database_name" {
  description = "Name of the database to create for this server"
  type        = "string"
}

variable "database_sku" {
  description = "SKU for the database with tier and size. Example {tier=\"Standard\", size=\"S1\"}"
  type        = "map"
}

variable "database_max_size" {
  description = "Maximum size of the database in bytes"
  type        = "string"
}

variable "databases_collation" {
  description = "SQL Collation for the database"
  default     = "SQL_LATIN1_GENERAL_CP1_CI_AS"
}

variable "logs_retention" {
  description = "Retention in days for audit logs on Storage Account"
  type        = "string"
  default     = "30"
}

variable "logs_storage_account_name" {
  description = "Storage Account name for database logs"
  type        = "string"
}

variable "logs_storage_account_rg" {
  description = "Storage Account Resource Group name for database logs"
  type        = "string"
}
