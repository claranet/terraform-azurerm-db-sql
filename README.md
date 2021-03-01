# Azure SQL
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/db-sql/azurerm/)

This Terraform module creates an [Azure SQL Server](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-servers)
and associated databases in an optional [SQL Elastic Pool](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-elastic-pool)
with [DTU purchasing model](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-service-tiers-dtu) or [vCore purchasing model](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-vcore-elastic-pools)
only along with [Firewall rules](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-firewall-configure)
and [Diagnostic settings](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-metrics-diag-logging)
enabled.



## Limitations

* The long term backup retention configuration is done asynchronously since the command lasts a long time.
  Command result is never fetch, only a check on Azure allows to know if configuration went fine.

<!-- BEGIN_TF_DOCS -->
## Global versioning rule for Claranet Azure modules

| Module version | Terraform version | AzureRM version |
| -------------- | ----------------- | --------------- |
| >= 6.x.x       | 1.x               | >= 3.0          |
| >= 5.x.x       | 0.15.x            | >= 2.0          |
| >= 4.x.x       | 0.13.x / 0.14.x   | >= 2.0          |
| >= 3.x.x       | 0.12.x            | >= 2.0          |
| >= 2.x.x       | 0.12.x            | < 2.0           |
| <  2.x.x       | 0.11.x            | < 2.0           |

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

```hcl
locals {
  databases_configuration = [
    {
      name                        = "db1"
      create_mode                 = "Default"
      max_size_gb                 = "10"
      min_capacity                = "3"
      auto_pause_delay_in_minutes = "3"
      elastic_pool_enabled        = true
      retention_days              = "20"
      database_extra_tags = {
        "dbname" = "db1"
      }
      threat_detection_policy = {
        state = false
      }
    },
    {
      name                        = "db2"
      create_mode                 = "Default"
      max_size_gb                 = "10"
      auto_pause_delay_in_minutes = "3"
      elastic_pool_enabled        = false
      retention_days              = "20"
      sku_name                    = "GP_Gen5_2"
      database_extra_tags = {
        "tag1"   = "tag1value"
        "dbname" = "db2"
      }
      short_term_retention_policy = {
        retention_days = 20
      }
      long_term_retention_policy = {
        weekly_retention  = "P1M"
        monthly_retention = "P1Y"
        yearly_retention  = "P1Y"
        week_of_year      = "3"
      }
      threat_detection_policy = {
        state                      = "Enabled"
        email_addresses            = ["john@doe.net"]
        storage_endpoint           = "https://myaccount.blob.core.windows.net/"
        storage_account_access_key = "storage_account_access_key"
      }
      extended_auditing_policy = {
        retention_days = 8
      }
    },
  ]
  custom_users = [
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
  administrator_login = "adminsqltest"
}



module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure_region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack

}

module "logs" {
  source  = "claranet/run-common/azurerm//modules/logs"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  resource_group_name = module.rg.resource_group_name
}

resource "random_password" "admin_password" {

  special          = true
  override_special = "#$%&-_+{}<>:"
  upper            = true
  lower            = true
  number           = true
  length           = 32
}


module "sql" {
  source  = "claranet/db-sql/azurerm"
  version = "x.x.x"

  client_name    = var.client_name
  environment    = var.environment
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  administrator_login    = local.administrator_login
  administrator_password = random_password.admin_password.result

  sku = {
    # Tier Basic/Standard/Premium are based on DTU
    tier     = "Standard"
    capacity = "100"
  }
  create_databases_users = true

  elasticpool_enabled   = true
  elastic_pool_max_size = "50"

  logs_destinations_ids = [
    module.logs.log_analytics_workspace_id,
    module.logs.logs_storage_account_id,
  ]

  databases_configuration = local.databases_configuration
  custom_users            = local.custom_users

}

```

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 2.44 |
| mssql | 0.2.3 |
| random | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| custom\_users | ./modules/custom_users | n/a |
| db\_logging | claranet/diagnostic-settings/azurerm | 4.0.3 |
| pool\_logging | claranet/diagnostic-settings/azurerm | 4.0.3 |
| single\_db\_logging | claranet/diagnostic-settings/azurerm | 4.0.3 |

## Resources

| Name | Type |
|------|------|
| [azurerm_mssql_database.db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_elasticpool.elastic_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_elasticpool) | resource |
| [azurerm_sql_firewall_rule.firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sql_firewall_rule) | resource |
| [azurerm_sql_server.server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sql_server) | resource |
| [azurerm_sql_virtual_network_rule.vnet_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sql_virtual_network_rule) | resource |
| [mssql_login.sql_login](https://registry.terraform.io/providers/betr-io/mssql/0.2.3/docs/resources/login) | resource |
| [mssql_user.sql_user](https://registry.terraform.io/providers/betr-io/mssql/0.2.3/docs/resources/user) | resource |
| [random_password.db_passwords](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| administrator\_login | Administrator login for SQL Server | `string` | n/a | yes |
| administrator\_password | Administrator password for SQL Server | `string` | n/a | yes |
| allowed\_cidr\_list | Allowed IP addresses to access the server in CIDR format. Default to all Azure services | `list(string)` | <pre>[<br>  "0.0.0.0/32"<br>]</pre> | no |
| allowed\_subnets\_ids | List of Subnet ID to allow to connect to the SQL Instance | `list(string)` | `[]` | no |
| client\_name | Client name/account used in naming | `string` | n/a | yes |
| create\_databases\_users | True to create a user named <db>\_user per database with generated password and role db\_owner. | `bool` | `true` | no |
| custom\_users | List of objects for custom users creation. <br>    Password are generated.<br>    These users are created within the "custom\_users" submodule.<br>    [<br>      {<br>        database\_name = "db1"<br>        user\_name     = "db1\_custom1"<br>        roles         = ["db\_accessadmin", "db\_securityadmin"]<br>      },<br>      {<br>        database\_name = "db1"<br>        user\_name     = "db1\_custom2"<br>        roles         = ["db\_accessadmin", "db\_securityadmin"]<br>      },<br>      {<br>        database\_name = "db2"<br>        user\_name     = "db2\_custom1"<br>        roles         = []<br>      },<br>      {<br>        database\_name = "db2"<br>        user\_name     = "db2\_custom2"<br>        roles         = ["db\_accessadmin", "db\_securityadmin"]<br>      }<br>  ] | <pre>list(object({<br>    name     = string<br>    database = string<br>    roles    = optional(list(string))<br>  }))</pre> | `[]` | no |
| databases\_configuration | List of databases configurations (see https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | <pre>list(object({<br>    auto_pause_delay_in_minutes = optional(number)<br>    collation                   = optional(string)<br>    create_mode                 = string<br>    creation_source_database_id = optional(string)<br>    database_extra_tags         = optional(map(string))<br>    elastic_pool_enabled        = optional(bool)<br>    geo_backup_enabled          = optional(bool)<br>    license_type                = optional(string)<br>    long_term_retention_policy  = optional(map(string))<br>    max_size_gb                 = optional(number)<br>    min_capacity                = optional(number)<br>    name                        = string<br>    read_replica_count          = optional(number)<br>    read_scale                  = optional(bool)<br>    recover_database_id         = optional(string)<br>    restore_dropped_database_id = optional(string)<br>    restore_point_in_time       = optional(string)<br>    short_term_retention_policy = optional(map(number))<br>    # This can costs you money https://docs.microsoft.com/en-us/azure/sql-database/sql-database-advanced-data-security<br>    threat_detection_policy = optional(object({<br>      disabled_alerts      = optional(list(string))<br>      email_account_admins = optional(string)<br>      email_addresses      = optional(list(string))<br>      retention_days       = optional(number)<br>      state                = string<br>      #those two parameters are required if state is enabled<br>      storage_account_access_key = optional(string)<br>      storage_endpoint           = optional(string)<br>      use_server_default         = optional(string)<br>    }))<br>    storage_account_type = optional(string)<br>    sku_name             = optional(string)<br>    zone_redundant       = optional(bool)<br>  }))</pre> | `[]` | no |
| databases\_extra\_tags | Extra tags to add on the SQL databases | `map(string)` | `{}` | no |
| default\_tags\_enabled | Option to enable or disable default tags | `bool` | `true` | no |
| elastic\_pool\_custom\_name | Name of the SQL Elastic Pool, generated if not set. | `string` | `""` | no |
| elastic\_pool\_database\_max\_capacity | The maximum capacity (DTU or vCore) any one database can consume in the Elastic Pool. Default to the max Elastic Pool capacity. | `string` | `""` | no |
| elastic\_pool\_database\_min\_capacity | The minimum capacity (DTU or vCore) all databases are guaranteed in the Elastic Pool. Defaults to 0. | `string` | `"0"` | no |
| elastic\_pool\_extra\_tags | Extra tags to add on ElasticPool | `map(string)` | `{}` | no |
| elastic\_pool\_max\_size | Maximum size of the Elastic Pool in gigabytes | `string` | `null` | no |
| elastic\_pool\_zone\_redundant | Whether or not the Elastic Pool is zone redundant, SKU tier must be Premium to use it. This is mandatory for high availability. | `bool` | `false` | no |
| elasticpool\_enabled | Whether or not create an Elastic Pool for the Sql. | `bool` | `false` | no |
| environment | Project environment | `string` | n/a | yes |
| extra\_tags | Extra tags to add | `map(string)` | `{}` | no |
| location | Azure location for SQL Server. | `string` | n/a | yes |
| location\_short | Short string for Azure location. | `string` | n/a | yes |
| logs\_destinations\_ids | List of destination resources Ids for logs diagnostics destination. Can be Storage Account, Log Analytics Workspace and Event Hub. No more than one of each can be set. Empty list to disable logging. | `list(string)` | n/a | yes |
| name\_prefix | Optional prefix for the generated name | `string` | `""` | no |
| resource\_group\_name | Resource group name | `string` | n/a | yes |
| server\_custom\_name | Name of the SQL Server, generated if not set. | `string` | `""` | no |
| server\_extra\_tags | Extra tags to add on SQL Server or ElasticPool | `map(string)` | `{}` | no |
| server\_version | Version of the SQL Server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). See https://www.terraform.io/docs/providers/azurerm/r/sql_server.html#version | `string` | `"12.0"` | no |
| sku | SKU for the Elastic Pool with tier and eDTUs capacity. Premium tier with zone redundancy is mandatory for high availability.<br>    Possible values for tier are "GP\_Ben5", "BC\_Gen5" for vCore models and "Basic", "Standard", or "Premium" for DTU based models. Example {tier="Standard", capacity="50"}.<br>    See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-dtu-resource-limits-elastic-pools" | <pre>object({<br>    tier     = string,<br>    capacity = number,<br>  })</pre> | `null` | no |
| stack | Project stack name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| custom\_databases\_users | Map of the custom SQL Databases users |
| custom\_databases\_users\_passwords | Map of the custom SQL Databases users passwords |
| custom\_databases\_users\_roles | Map of the custom SQL Databases users roles |
| default\_administrator\_databases\_connection\_strings | Map of the SQL Databases with administrator credentials connection strings |
| default\_databases\_users | Map of the SQL Databases dedicated users |
| default\_databases\_users\_passwords | Map of the SQL Databases dedicated passwords |
| sql\_administrator\_login | SQL Administrator login |
| sql\_administrator\_password | SQL Administrator password |
| sql\_databases | SQL Databases |
| sql\_databases\_id | Map of the SQL Databases IDs |
| sql\_elastic\_pool\_id | ID of the SQL Elastic Pool |
| sql\_server | SQL Server FQDN |
| sql\_server\_id | SQL Server ID |
| terraform\_module | Information about this Terraform module |
<!-- END_TF_DOCS -->
## Related documentation

Microsoft Azure root documentation: [docs.microsoft.com/en-us/azure/sql-database/](https://docs.microsoft.com/en-us/azure/sql-database/)
