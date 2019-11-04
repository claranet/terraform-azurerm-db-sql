variable "client_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "stack" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  description = "Azure location for SQL Server."
  type        = string
}

variable "location_short" {
  description = "Short string for Azure location."
  type        = string
}

variable "name_prefix" {
  description = "Optional prefix for the generated name"
  type        = string
  default     = ""
}

variable "server_version" {
  description = "Version of the SQL Server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). See https://www.terraform.io/docs/providers/azurerm/r/sql_server.html#version"
  type        = string
  default     = "12.0"
}

variable "allowed_cidr_list" {
  description = "Allowed IP addresses to access the server in CIDR format. Default to all Azure services"
  type        = list(string)
  default     = ["0.0.0.0/32"]
}

variable "extra_tags" {
  description = "Extra tags to add"
  type        = map(string)
  default     = {}
}

variable "server_extra_tags" {
  description = "Extra tags to add on SQL Server"
  type        = map(string)
  default     = {}
}

variable "elastic_pool_extra_tags" {
  description = "Extra tags to add on the SQL Elastic Pool"
  type        = map(string)
  default     = {}
}

variable "databases_extra_tags" {
  description = "Extra tags to add on the SQL databases"
  type        = map(string)
  default     = {}
}

variable "server_custom_name" {
  description = "Name of the SQL Server, generated if not set."
  type        = string
  default     = ""
}

variable "elastic_pool_custom_name" {
  description = "Name of the SQL Elastic Pool, generated if not set."
  type        = string
  default     = ""
}

variable "administrator_login" {
  description = "Administrator login for SQL Server"
  type        = string
}

variable "administrator_password" {
  description = "Administrator password for SQL Server"
  type        = string
}

variable "elastic_pool_max_size" {
  description = "Maximum size of the Elastic Pool in gigabytes"
  type        = string
}

variable "sku" {
  description = <<DESC
    SKU for the Elastic Pool with tier and eDTUs capacity. Premium tier with zone redundancy is mandatory for high availability.
    Possible values for tier are "Basic", "Standard", or "Premium". Example {tier="Standard", capacity="50"}.
    See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-dtu-resource-limits-elastic-pools"
DESC

  type = map(string)
}

variable "zone_redundant" {
  description = "Whether or not the Elastic Pool is zone redundant, SKU tier must be Premium to use it. This is mandatory for high availability."
  type        = string
  default     = "false"
}

variable "database_min_dtu_capacity" {
  description = "The minimum capacity all databases are guaranteed in the Elastic Pool. Defaults to 0."
  type        = string
  default     = "0"
}

variable "database_max_dtu_capacity" {
  description = "The maximum capacity any one database can consume in the Elastic Pool. Default to the max Elastic Pool capacity."
  type        = string
  default     = ""
}

variable "databases_names" {
  description = "Names of the databases to create for this server"
  type        = list(string)
}

variable "databases_collation" {
  description = "SQL Collation for the databases"
  type        = string
  default     = "SQL_LATIN1_GENERAL_CP1_CI_AS"
}

variable "enable_logging" {
  description = "Boolean flag to specify whether logging is enabled"
  type        = bool
  default     = true
}

variable "logs_storage_retention" {
  description = "Retention in days for logs on Storage Account"
  type        = string
  default     = "30"
}

variable "logs_storage_account_id" {
  description = "Storage Account id for logs"
  type        = string
  default     = null
}

variable "logs_log_analytics_workspace_id" {
  description = "Log Analytics Workspace id for logs"
  type        = string
  default     = null
}

variable "enable_advanced_data_security" {
  description = "Boolean flag to enable Advanced Data Security. The cost of ADS is aligned with Azure Security Center standard tier pricing. See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-advanced-data-security"
  type        = string
  default     = "false"
}

variable "enable_advanced_data_security_admin_emails" {
  description = "Boolean flag to define if account administrators should be emailed with Advanced Data Security alerts."
  type        = string
  default     = "false"
}

variable "advanced_data_security_additional_emails" {
  description = "List of addiional email addresses for Advanced Data Security alerts."
  type        = list(string)

  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/1974
  default = ["john.doe@azure.com"]
}

variable "create_databases_users" {
  description = "True to create a user named <db>_user per database with generated password and role db_owner."
  type        = string
  default     = "true"
}

variable "daily_backup_retention" {
  description = "Retention in days for the databases backup. Value can be 7, 14, 21, 28 or 35."
  type        = number
  default     = 35
}

variable "weekly_backup_retention" {
  description = "Retention in weeks for the weekly databases backup."
  type        = number
  default     = 0
}

variable "monthly_backup_retention" {
  description = "Retention in months for the monthly databases backup."
  type        = number
  default     = 3
}

variable "yearly_backup_retention" {
  description = "Retention in years for the yearly backup."
  type        = number
  default     = 0
}

variable "yearly_backup_time" {
  description = "Week number taken in account for the yearly backup retention."
  type        = number
  default     = 52
}
