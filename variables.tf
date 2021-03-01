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

variable "elasticpool_enabled" {
  description = "Whether or not create an Elastic Pool for the Sql."
  type        = bool
  default     = false
}

variable "elastic_pool_max_size" {
  description = "Maximum size of the Elastic Pool in gigabytes"
  type        = string
  default     = null
}

variable "elastic_pool_zone_redundant" {
  description = "Whether or not the Elastic Pool is zone redundant, SKU tier must be Premium to use it. This is mandatory for high availability."
  type        = bool
  default     = false
}

variable "elastic_pool_database_min_capacity" {
  description = "The minimum capacity (DTU or vCore) all databases are guaranteed in the Elastic Pool. Defaults to 0."
  type        = string
  default     = "0"
}

variable "elastic_pool_database_max_capacity" {
  description = "The maximum capacity (DTU or vCore) any one database can consume in the Elastic Pool. Default to the max Elastic Pool capacity."
  type        = string
  default     = ""
}

variable "elastic_pool_extra_tags" {
  description = "Extra tags to add on ElasticPool"
  type        = map(string)
  default     = {}
}

variable "administrator_login" {
  description = "Administrator login for SQL Server"
  type        = string
}

variable "administrator_password" {
  description = "Administrator password for SQL Server"
  type        = string
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

variable "logs_destinations_ids" {
  type        = list(string)
  description = "List of destination resources Ids for logs diagnostics destination. Can be Storage Account, Log Analytics Workspace and Event Hub. No more than one of each can be set. Empty list to disable logging."
}

variable "create_databases_users" {
  description = "True to create a user named <db>_user per database with generated password and role db_owner."
  type        = bool
  default     = true
}

variable "allowed_subnets_ids" {
  description = "List of Subnet ID to allow to connect to the SQL Instance"
  type        = list(string)
  default     = []
}

variable "custom_users" {
  description = <<DESC
    List of objects for custom users creation. 
    Password are generated.
    These users are created within the "custom_users" submodule.
    [
      {
        database_name = "db1"
        user_name     = "db1_custom1"
        roles         = ["db_accessadmin", "db_securityadmin"]
      },
      {
        database_name = "db1"
        user_name     = "db1_custom2"
        roles         = ["db_accessadmin", "db_securityadmin"]
      },
      {
        database_name = "db2"
        user_name     = "db2_custom1"
        roles         = []
      },
      {
        database_name = "db2"
        user_name     = "db2_custom2"
        roles         = ["db_accessadmin", "db_securityadmin"]
      }
  ]
DESC
  type = list(object({
    name     = string
    database = string
    roles    = optional(list(string))
  }))
  default = []
}

variable "databases_configuration" {
  description = "List of databases configurations (see https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database)"
  type = list(object({
    auto_pause_delay_in_minutes = optional(number)
    collation                   = optional(string)
    create_mode                 = string
    creation_source_database_id = optional(string)
    database_extra_tags         = optional(map(string))
    elastic_pool_enabled        = optional(bool)
    geo_backup_enabled          = optional(bool)
    license_type                = optional(string)
    long_term_retention_policy  = optional(map(string))
    max_size_gb                 = optional(number)
    min_capacity                = optional(number)
    name                        = string
    read_replica_count          = optional(number)
    read_scale                  = optional(bool)
    recover_database_id         = optional(string)
    restore_dropped_database_id = optional(string)
    restore_point_in_time       = optional(string)
    short_term_retention_policy = optional(map(number))
    # This can costs you money https://docs.microsoft.com/en-us/azure/sql-database/sql-database-advanced-data-security
    threat_detection_policy = optional(object({
      disabled_alerts      = optional(list(string))
      email_account_admins = optional(string)
      email_addresses      = optional(list(string))
      retention_days       = optional(number)
      state                = string
      #those two parameters are required if state is enabled
      storage_account_access_key = optional(string)
      storage_endpoint           = optional(string)
      use_server_default         = optional(string)
    }))
    storage_account_type = optional(string)
    sku_name             = optional(string)
    zone_redundant       = optional(bool)
  }))
  default = []
}
