# Azure SQL
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/db-sql/azurerm/)

This Terraform module creates an [Azure SQL Server](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-servers)
and associated databases in an [SQL Elastic Pool](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-elastic-pool)
with [DTU purchasing model](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-service-tiers-dtu) or [vCore purchasing model](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-vcore-elastic-pools)
only along with [Firewall rules](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-firewall-configure)
and [Diagnostic settings](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-metrics-diag-logging)
enabled.

## Requirements

* [PowerShell with Az.Sql module](https://docs.microsoft.com/en-us/powershell/module/az.sql/) >= 1.3 is mandatory and is used for backup retention configuration
* [`SqlServer` Powershell module](https://docs.microsoft.com/en-us/sql/powershell/sql-server-powershell) is needed for databases users creation
* [pymssql](https://www.pymssql.org/) >= 2.1.5
* [FreeTDS](https://www.freetds.org/) >= 0.9.1 (Only on OSX. Static copy of FreeTDS is embeeded on Linux and Windows pymssql bundle)
* [Python](https://www.python.org) >= 3.8

## Version compatibility

| Module version    | Terraform version | AzureRM version |
|-------------------|-------------------|-----------------|
| >= 5.x.x          | 0.14.x            | >= 2.0          |
| >= 4.x.x          | 0.13.x            | >= 2.0          |
| >= 3.x.x          | 0.12.x            | >= 2.0          |
| >= 2.x.x, < 3.x.x | 0.12.x            | <  2.0          |
| <  2.x.x          | 0.11.x            | <  2.0          |

## Limitations

* The long term backup retention configuration is done asynchronously since the command lasts a long time.
  Command result is never fetch, only a check on Azure allows to know if configuration went fine.

## Usage

You can use this module by including it this way:
```hcl
module "azure-region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure-region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

module "sql-dtu" {
  source  = "claranet/db-sql/azurerm"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  location            = module.azure-region.location
  location_short      = module.azure-region.location_short
  resource_group_name = module.rg.resource_group_name
  stack               = var.stack

  elasticpool_databases = ["users", "documents"]

  administrator_login    = "claranet"
  administrator_password = var.sql_admin_password

  sku = {
    // Tier Basic/Standard/Premium are based on DTU
    tier     = "Standard"
    capacity = "100"
  }

  elastic_pool_max_size = "50"

  # This can costs you money https://docs.microsoft.com/en-us/azure/sql-database/sql-database-advanced-data-security
  enable_advanced_data_security = true

  logs_destinations_ids = [
    data.terraform_remote_state.run.outputs.log_analytics_workspace_id,
    data.terraform_remote_state.run.outputs.logs_storage_account_id,
  ]
}

module "sql-vcore" {
  source  = "claranet/db-sql/azurerm"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  location            = module.azure-region.location
  location_short      = module.azure-region.location_short
  resource_group_name = module.rg.resource_group_name
  stack               = var.stack

  databases_names = ["users", "documents"]

  administrator_login    = "claranet"
  administrator_password = var.sql_admin_password

  sku = {
    // GeneralPurpose or BusinessCritical will actiate the vCore based model on Gen5 hardware
    tier     = "GeneralPurpose"
    capacity = 2
  }

  elastic_pool_max_size = "50"

  logs_destinations_ids = [
    data.terraform_remote_state.run.outputs.log_analytics_workspace_id,
    data.terraform_remote_state.run.outputs.logs_storage_account_id
  ]

  allowed_subnets_ids = [
    "/subscriptions/xxxxxx/resourceGroups/xxxxxx/providers/Microsoft.Network/virtualNetworks/vnetxxxxxx/subnets/subnetxxxxx",
  ]
}

module "sql-custom-users" {
  source  = "claranet/db-sql/azurerm"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  location            = module.azure-region.location
  location_short      = module.azure-region.location_short
  resource_group_name = module.rg.resource_group_name
  stack               = var.stack

  databases_names = ["users", "documents"]

  administrator_login    = "claranet"
  administrator_password = var.sql_admin_password

  sku = {
    // GeneralPurpose or BusinessCritical will actiate the vCore based model on Gen5 hardware
    tier     = "GeneralPurpose"
    capacity = 2
  }

  elastic_pool_max_size = "50"

  logs_destinations_ids = [
    data.terraform_remote_state.run.outputs.log_analytics_workspace_id,
    data.terraform_remote_state.run.outputs.logs_storage_account_id
  ]

  custom_users = [
    {
      name     = "User1"
      database = "MyDB1"
      roles    = ["db_datareader", "db_datawriter"]
    },
    {
      name     = "UserAdmin"
      database = "MyDB1"
      roles    = ["db_owner"]
    }
  ]

}
module "sql-single" {
  source  = "claranet/db-sql/azurerm"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  location            = module.azure-region.location
  location_short      = module.azure-region.location_short
  resource_group_name = module.rg.resource_group_name
  stack               = var.stack

  single_databases_configuration = [
    {
      name                        = "document"
      max_size_gb                 = 100
      sku_name                    = "GP_S_Gen5_4"
      min_capacity                = 0.5
      auto_pause_delay_in_minutes = 60
      storage_account_type        = "GRS"
      retention_days              = 14
    },
    {
      name                        = "users"
      max_size_gb                 = 100
      sku_name                    = "GP_S_Gen5_4"
      min_capacity                = 0.5
      auto_pause_delay_in_minutes = 60
      storage_account_type        = "GRS"
      retention_days              = 14
    }
  ]

  administrator_login    = "claranet"
  administrator_password = var.sql_admin_password

  enable_elasticpool = false


  logs_destinations_ids = [
    module.run.log_analytics_workspace_id,
    module.run.logs_storage_account_id,
  ]

}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| administrator\_login | Administrator login for SQL Server | `string` | n/a | yes |
| administrator\_password | Administrator password for SQL Server | `string` | n/a | yes |
| advanced\_data\_security\_additional\_emails | List of addiional email addresses for Advanced Data Security alerts. | `list(string)` | <pre>[<br>  "john.doe@azure.com"<br>]</pre> | no |
| allowed\_cidr\_list | Allowed IP addresses to access the server in CIDR format. Default to all Azure services | `list(string)` | <pre>[<br>  "0.0.0.0/32"<br>]</pre> | no |
| allowed\_subnets\_ids | List of Subnet ID to allow to connect to the SQL Instance | `list(string)` | `[]` | no |
| client\_name | n/a | `string` | n/a | yes |
| create\_databases\_users | True to create a user named <db>\_user per database with generated password and role db\_owner. | `bool` | `true` | no |
| custom\_users | Create custom users with associated roles | <pre>list(object({<br>    name     = string,<br>    database = string,<br>    roles    = list(string)<br>  }))</pre> | `[]` | no |
| daily\_backup\_retention | Retention in days for the elastic pool databases backup. Value can be 7, 14, 21, 28 or 35. | `number` | `35` | no |
| database\_max\_capacity | The maximum capacity (DTU or vCore) any one database can consume in the Elastic Pool. Default to the max Elastic Pool capacity. | `string` | `""` | no |
| database\_min\_capacity | The minimum capacity (DTU or vCore) all databases are guaranteed in the Elastic Pool. Defaults to 0. | `string` | `"0"` | no |
| databases\_collation | SQL Collation for the databases | `string` | `"SQL_LATIN1_GENERAL_CP1_CI_AS"` | no |
| databases\_extra\_tags | Extra tags to add on the SQL databases | `map(string)` | `{}` | no |
| elastic\_pool\_custom\_name | Name of the SQL Elastic Pool, generated if not set. | `string` | `""` | no |
| elastic\_pool\_max\_size | Maximum size of the Elastic Pool in gigabytes | `string` | `null` | no |
| elasticpool\_databases | Names of the databases to create in elastic pool for this server. Use only if enable\_elasticpool is true. | `list(string)` | `[]` | no |
| enable\_advanced\_data\_security | Boolean flag to enable Advanced Data Security. The cost of ADS is aligned with Azure Security Center standard tier pricing. See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-advanced-data-security | `bool` | `false` | no |
| enable\_advanced\_data\_security\_admin\_emails | Boolean flag to define if account administrators should be emailed with Advanced Data Security alerts. | `bool` | `false` | no |
| enable\_elasticpool | Deploy the databases in an ElasticPool if enabled. Otherwise, deploy single databases. | `bool` | `true` | no |
| environment | n/a | `string` | n/a | yes |
| extra\_tags | Extra tags to add | `map(string)` | `{}` | no |
| location | Azure location for SQL Server. | `string` | n/a | yes |
| location\_short | Short string for Azure location. | `string` | n/a | yes |
| logs\_destinations\_ids | List of destination resources Ids for logs diagnostics destination. Can be Storage Account, Log Analytics Workspace and Event Hub. No more than one of each can be set. Empty list to disable logging. | `list(string)` | n/a | yes |
| monthly\_backup\_retention | Retention in months for the monthly databases backup. | `number` | `3` | no |
| name\_prefix | Optional prefix for the generated name | `string` | `""` | no |
| resource\_group\_name | n/a | `string` | n/a | yes |
| server\_custom\_name | Name of the SQL Server, generated if not set. | `string` | `""` | no |
| server\_extra\_tags | Extra tags to add on SQL Server or ElasticPool | `map(string)` | `{}` | no |
| server\_version | Version of the SQL Server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). See https://www.terraform.io/docs/providers/azurerm/r/sql_server.html#version | `string` | `"12.0"` | no |
| single\_databases\_configuration | List of databases configurations (see https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) without elasticpool. Use only if enable\_elasticpool is false. | <pre>list(object({<br>    name                        = string<br>    sku_name                    = optional(string)<br>    collation                   = optional(string)<br>    max_size_gb                 = optional(number)<br>    zone_redundant              = optional(bool)<br>    min_capacity                = optional(number)<br>    auto_pause_delay_in_minutes = optional(number)<br>    threat_detection_policy = optional(object({<br>      state = bool<br>    }))<br>    retention_days      = optional(number)<br>    weekly_retention    = optional(number)<br>    monthly_retention   = optional(number)<br>    yearly_retention    = optional(number)<br>    week_of_year        = optional(number)<br>    database_extra_tags = optional(map(any))<br>  }))</pre> | `[]` | no |
| sku | SKU for the Elastic Pool with tier and eDTUs capacity. Premium tier with zone redundancy is mandatory for high availability.<br>    Possible values for tier are "GP\_Ben5", "BC\_Gen5" for vCore models and "Basic", "Standard", or "Premium" for DTU based models. Example {tier="Standard", capacity="50"}.<br>    See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-dtu-resource-limits-elastic-pools" | <pre>object({<br>    tier     = string,<br>    capacity = number,<br>  })</pre> | `null` | no |
| stack | n/a | `string` | n/a | yes |
| weekly\_backup\_retention | Retention in weeks for the weekly databases backup. | `number` | `0` | no |
| yearly\_backup\_retention | Retention in years for the yearly backup. | `number` | `0` | no |
| yearly\_backup\_time | Week number taken in account for the yearly backup retention. | `number` | `52` | no |
| zone\_redundant | Whether or not the Elastic Pool is zone redundant, SKU tier must be Premium to use it. This is mandatory for high availability. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| custom\_users\_passwords | Map of the custom users passwords |
| databases\_single\_ids | MSSQL Database single IDs |
| databases\_users | Map of the SQL Databases dedicated usernames |
| databases\_users\_passwords | Map of the SQL Databases dedicated passwords |
| default\_administrator\_databases\_connection\_strings | Map of the SQL Databases with administrator credentials connection strings |
| sql\_databases | SQL Databases |
| sql\_databases\_creation\_date | Map of the SQL Databases creation dates |
| sql\_databases\_default\_secondary\_location | Map of the SQL Databases default secondary location |
| sql\_databases\_id | Map of the SQL Databases IDs |
| sql\_elastic\_pool | SQL Elastic Pool |
| sql\_elastic\_pool\_id | Id of the SQL Elastic Pool |
| sql\_server | SQL Server |

## Related documentation

Terraform SQL Server documentation: [terraform.io/docs/providers/azurerm/r/sql_server.html](https://www.terraform.io/docs/providers/azurerm/r/sql_server.html)

Terraform SQL Database documentation: [terraform.io/docs/providers/azurerm/r/sql_database.html](https://www.terraform.io/docs/providers/azurerm/r/sql_database.html)

Terraform SQL Elastic Pool documentation: [terraform.io/docs/providers/azurerm/r/mssql_elasticpool.html](https://www.terraform.io/docs/providers/azurerm/r/mssql_elasticpool.html)

Microsoft Azure root documentation: [docs.microsoft.com/en-us/azure/sql-database/](https://docs.microsoft.com/en-us/azure/sql-database/)
