variable "client_name" {
  description = "Client name/account used in naming"
  type        = string
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "stack" {
  description = "Project stack name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
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
  description = "Extra tags to add on SQL Server or ElasticPool"
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
  default     = null
}

variable "sku" {
  description = <<DESC
    SKU for the Elastic Pool with tier and eDTUs capacity. Premium tier with zone redundancy is mandatory for high availability.
    Possible values for tier are "GP_Ben5", "BC_Gen5" for vCore models and "Basic", "Standard", or "Premium" for DTU based models. Example {tier="Standard", capacity="50"}.
    See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-dtu-resource-limits-elastic-pools"
DESC

  type = object({
    tier     = string,
    capacity = number,
  })
  default = null
}

variable "zone_redundant" {
  description = "Whether or not the Elastic Pool is zone redundant, SKU tier must be Premium to use it. This is mandatory for high availability."
  type        = bool
  default     = false
}

variable "database_min_capacity" {
  description = "The minimum capacity (DTU or vCore) all databases are guaranteed in the Elastic Pool. Defaults to 0."
  type        = string
  default     = "0"
}

variable "database_max_capacity" {
  description = "The maximum capacity (DTU or vCore) any one database can consume in the Elastic Pool. Default to the max Elastic Pool capacity."
  type        = string
  default     = ""
}

variable "elasticpool_databases" {
  description = "Names of the databases to create in elastic pool for this server. Use only if enable_elasticpool is true."
  type        = list(string)
  default     = []
}

variable "databases_collation" {
  description = "SQL Collation for the databases"
  type        = string
  default     = "SQL_LATIN1_GENERAL_CP1_CI_AS"
}

variable "logs_destinations_ids" {
  type        = list(string)
  description = "List of destination resources Ids for logs diagnostics destination. Can be Storage Account, Log Analytics Workspace and Event Hub. No more than one of each can be set. Empty list to disable logging."
}

variable "enable_advanced_data_security" {
  description = "Boolean flag to enable Advanced Data Security. The cost of ADS is aligned with Azure Security Center standard tier pricing. See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-advanced-data-security"
  type        = bool
  default     = false
}

variable "enable_advanced_data_security_admin_emails" {
  description = "Boolean flag to define if account administrators should be emailed with Advanced Data Security alerts."
  type        = bool
  default     = false
}

variable "advanced_data_security_additional_emails" {
  description = "List of addiional email addresses for Advanced Data Security alerts."
  type        = list(string)

  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/1974
  default = ["john.doe@azure.com"]
}

variable "create_databases_users" {
  description = "True to create a user named <db>_user per database with generated password and role db_owner."
  type        = bool
  default     = true
}

variable "daily_backup_retention" {
  description = "Retention in days for the elastic pool databases backup. Value can be 7, 14, 21, 28 or 35."
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

variable "allowed_subnets_ids" {
  description = "List of Subnet ID to allow to connect to the SQL Instance"
  type        = list(string)
  default     = []
}

variable "custom_users" {
  description = "Create custom users with associated roles"
  type = list(object({
    name     = string,
    database = string,
    roles    = list(string)
  }))
  default = []
}

variable "enable_elasticpool" {
  description = "Deploy the databases in an ElasticPool if enabled. Otherwise, deploy single databases."
  type        = bool
  default     = true
}

variable "single_databases_configuration" {
  description = "List of databases configurations (see https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) without elasticpool. Use only if enable_elasticpool is false. "
  type = list(object({
    name                        = string
    sku_name                    = optional(string)
    collation                   = optional(string)
    max_size_gb                 = optional(number)
    zone_redundant              = optional(bool)
    min_capacity                = optional(number)
    auto_pause_delay_in_minutes = optional(number)
    threat_detection_policy = optional(object({
      state = bool
    }))
    retention_days      = optional(number)
    weekly_retention    = optional(number)
    monthly_retention   = optional(number)
    yearly_retention    = optional(number)
    week_of_year        = optional(number)
    database_extra_tags = optional(map(any))
  }))
  default = []
}
