# Azure SQL
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/db-sql/azurerm/)

This Terraform module creates an [Azure SQL Server](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-servers)
and associated databases in an optional [SQL Elastic Pool](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-elastic-pool)
with [DTU purchasing model](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-service-tiers-dtu) or [vCore purchasing model](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-vcore-elastic-pools)
only along with [Firewall rules](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-firewall-configure)
and [Diagnostic settings](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-metrics-diag-logging)
enabled.

<!-- BEGIN_TF_DOCS -->
## Global versioning rule for Claranet Azure modules

| Module version | Terraform version | AzureRM version |
| -------------- | ----------------- | --------------- |
| >= 7.x.x       | 1.3.x             | >= 3.0          |
| >= 6.x.x       | 1.x               | >= 3.0          |
| >= 5.x.x       | 0.15.x            | >= 2.0          |
| >= 4.x.x       | 0.13.x / 0.14.x   | >= 2.0          |
| >= 3.x.x       | 0.12.x            | >= 2.0          |
| >= 2.x.x       | 0.12.x            | < 2.0           |
| <  2.x.x       | 0.11.x            | < 2.0           |

## Contributing

If you want to contribute to this repository, feel free to use our [pre-commit](https://pre-commit.com/) git hook configuration
which will help you automatically update and format some files for you by enforcing our Terraform code module best-practices.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

```hcl
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
  source  = "claranet/run/azurerm//modules/logs"
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

# Elastic Pool
module "sql_elastic" {
  source  = "claranet/db-sql/azurerm"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  stack               = var.stack
  resource_group_name = module.rg.resource_group_name

  administrator_login    = "adminsqltest"
  administrator_password = random_password.admin_password.result
  create_databases_users = true

  elastic_pool_enabled  = true
  elastic_pool_max_size = "50"
  elastic_pool_sku = {
    tier     = "GeneralPurpose"
    capacity = 2
  }

  logs_destinations_ids = [
    module.logs.log_analytics_workspace_id,
    module.logs.logs_storage_account_id,
  ]

  databases = [
    {
      name        = "db1"
      max_size_gb = 50
    },
    {
      name        = "db2"
      max_size_gb = 180
    }
  ]

  custom_users = [
    {
      database = "db1"
      name     = "db1_custom1"
      roles    = ["db_accessadmin", "db_securityadmin"]
    },
    {
      database = "db1"
      name     = "db1_custom2"
      roles    = ["db_accessadmin", "db_securityadmin"]
    },
    {
      database = "db2"
      name     = "db2_custom1"
      roles    = []
    },
    {
      database = "db2"
      name     = "db2_custom2"
      roles    = ["db_accessadmin", "db_securityadmin"]
    }
  ]
}

# Single Database

module "sql_single" {
  source  = "claranet/db-sql/azurerm"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  stack               = var.stack
  resource_group_name = module.rg.resource_group_name

  administrator_login    = "adminsqltest"
  administrator_password = random_password.admin_password.result
  create_databases_users = true

  elastic_pool_enabled = false

  logs_destinations_ids = [
    module.logs.log_analytics_workspace_id,
    module.logs.logs_storage_account_id,
  ]

  databases = [
    {
      name        = "db1"
      max_size_gb = 50
    },
    {
      name        = "db2"
      max_size_gb = 180
    }
  ]

  custom_users = [
    {
      database = "db1"
      name     = "db1_custom1"
      roles    = ["db_accessadmin", "db_securityadmin"]
    },
    {
      database = "db1"
      name     = "db1_custom2"
      roles    = ["db_accessadmin", "db_securityadmin"]
    },
    {
      database = "db2"
      name     = "db2_custom1"
      roles    = []
    },
    {
      database = "db2"
      name     = "db2_custom2"
      roles    = ["db_accessadmin", "db_securityadmin"]
    }
  ]
}
```

## Providers

| Name | Version |
|------|---------|
| azurecaf | ~> 1.2, >= 1.2.22 |
| azurerm | ~> 3.39 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| custom\_users | ./modules/databases_users | n/a |
| databases\_users | ./modules/databases_users | n/a |
| elastic\_pool\_db\_logging | claranet/diagnostic-settings/azurerm | ~> 6.5.0 |
| pool\_logging | claranet/diagnostic-settings/azurerm | ~> 6.5.0 |
| single\_db\_logging | claranet/diagnostic-settings/azurerm | ~> 6.5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_mssql_database.elastic_pool_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_database.single_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_database_extended_auditing_policy.elastic_pool_db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database_extended_auditing_policy) | resource |
| [azurerm_mssql_database_extended_auditing_policy.single_db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database_extended_auditing_policy) | resource |
| [azurerm_mssql_elasticpool.elastic_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_elasticpool) | resource |
| [azurerm_mssql_firewall_rule.firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) | resource |
| [azurerm_mssql_server.sql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_mssql_server_extended_auditing_policy.sql_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_extended_auditing_policy) | resource |
| [azurerm_mssql_server_security_alert_policy.sql_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_security_alert_policy) | resource |
| [azurerm_mssql_server_vulnerability_assessment.sql_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_vulnerability_assessment) | resource |
| [azurerm_mssql_virtual_network_rule.vnet_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_network_rule) | resource |
| [azurecaf_name.sql](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.sql_dbs](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.sql_pool](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| administrator\_login | Administrator login for SQL Server | `string` | n/a | yes |
| administrator\_password | Administrator password for SQL Server | `string` | n/a | yes |
| alerting\_email\_addresses | List of email addresses to send reports for threat detection and vulnerability assesment | `list(string)` | `[]` | no |
| allowed\_cidr\_list | Allowed IP addresses to access the server in CIDR format. Default to all Azure services | `list(string)` | <pre>[<br>  "0.0.0.0/32"<br>]</pre> | no |
| allowed\_subnets\_ids | List of Subnet ID to allow to connect to the SQL Instance | `list(string)` | `[]` | no |
| azuread\_administrator | Azure AD Administrator configuration block of this SQL Server. | <pre>object({<br>    login_username              = optional(string)<br>    object_id                   = optional(string)<br>    tenant_id                   = optional(string)<br>    azuread_authentication_only = optional(bool)<br>  })</pre> | `null` | no |
| backup\_retention | Definition of long term backup retention for all the databases in this SQL Server. | <pre>object({<br>    weekly_retention  = optional(number)<br>    monthly_retention = optional(number)<br>    yearly_retention  = optional(number)<br>    week_of_year      = optional(number)<br>  })</pre> | `{}` | no |
| client\_name | Client name/account used in naming | `string` | n/a | yes |
| connection\_policy | The connection policy the server will use. Possible values are `Default`, `Proxy`, and `Redirect` | `string` | `"Default"` | no |
| create\_databases\_users | True to create a user named <db>\_user on each database with generated password and role db\_owner. | `bool` | `true` | no |
| custom\_diagnostic\_settings\_name | Custom name of the diagnostics settings, name will be 'default' if not set. | `string` | `"default"` | no |
| custom\_users | List of objects for custom users creation.<br>    Password are generated.<br>    These users are created within the "custom\_users" submodule. | <pre>list(object({<br>    name     = string<br>    database = string<br>    roles    = optional(list(string))<br>  }))</pre> | `[]` | no |
| databases | List of the databases configurations for this server. | <pre>list(object({<br>    name                        = string<br>    license_type                = optional(string)<br>    sku_name                    = optional(string)<br>    max_size_gb                 = number<br>    create_mode                 = optional(string)<br>    min_capacity                = optional(number)<br>    auto_pause_delay_in_minutes = optional(number)<br>    read_scale                  = optional(string)<br>    read_replica_count          = optional(number)<br>    creation_source_database_id = optional(string)<br>    restore_point_in_time       = optional(string)<br>    recover_database_id         = optional(string)<br>    restore_dropped_database_id = optional(string)<br>    storage_account_type        = optional(string, "Geo")<br>    database_extra_tags         = optional(map(string), {})<br>  }))</pre> | `[]` | no |
| databases\_collation | SQL Collation for the databases | `string` | `"SQL_Latin1_General_CP1_CI_AS"` | no |
| databases\_extended\_auditing\_enabled | True to enable extended auditing for SQL databases | `bool` | `false` | no |
| databases\_extended\_auditing\_retention\_days | Databases extended auditing logs retention | `number` | `30` | no |
| databases\_zone\_redundant | True to have databases zone redundant, which means the replicas of the databases will be spread across multiple availability zones. This property is only settable for `Premium` and `Business Critical` databases. | `bool` | `null` | no |
| default\_tags\_enabled | Option to enable or disable default tags | `bool` | `true` | no |
| elastic\_pool\_custom\_name | Name of the SQL Elastic Pool, generated if not set. | `string` | `""` | no |
| elastic\_pool\_databases\_max\_capacity | The maximum capacity (DTU or vCore) any one database can consume in the Elastic Pool. Default to the max Elastic Pool capacity. | `number` | `null` | no |
| elastic\_pool\_databases\_min\_capacity | The minimum capacity (DTU or vCore) all databases are guaranteed in the Elastic Pool. Defaults to 0. | `number` | `0` | no |
| elastic\_pool\_enabled | True to deploy the databases in an ElasticPool, single databases are deployed otherwise. | `bool` | `false` | no |
| elastic\_pool\_extra\_tags | Extra tags to add on ElasticPool | `map(string)` | `{}` | no |
| elastic\_pool\_license\_type | Specifies the license type applied to this database. Possible values are `LicenseIncluded` and `BasePrice` | `string` | `null` | no |
| elastic\_pool\_max\_size | Maximum size of the Elastic Pool in gigabytes | `string` | `null` | no |
| elastic\_pool\_sku | SKU for the Elastic Pool with tier and eDTUs capacity. Premium tier with zone redundancy is mandatory for high availability.<br>    Possible values for tier are `GeneralPurpose`, `BusinessCritical` for vCore models and `Basic`, `Standard`, or `Premium` for DTU based models.<br>    See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-dtu-resource-limits-elastic-pools" | <pre>object({<br>    tier     = string,<br>    capacity = number,<br>    family   = optional(string, "Gen5")<br>  })</pre> | `null` | no |
| elastic\_pool\_zone\_redundant | True to have the Elastic Pool zone redundant, SKU tier must be Premium to use it. This is mandatory for high availability. | `bool` | `false` | no |
| environment | Project environment | `string` | n/a | yes |
| extra\_tags | Extra tags to add | `map(string)` | `{}` | no |
| location | Azure location for SQL Server. | `string` | n/a | yes |
| location\_short | Short string for Azure location. | `string` | n/a | yes |
| logs\_categories | Log categories to send to destinations. | `list(string)` | `null` | no |
| logs\_destinations\_ids | List of destination resources IDs for logs diagnostic destination.<br>Can be `Storage Account`, `Log Analytics Workspace` and `Event Hub`. No more than one of each can be set.<br>If you want to specify an Azure EventHub to send logs and metrics to, you need to provide a formated string with both the EventHub Namespace authorization send ID and the EventHub name (name of the queue to use in the Namespace) separated by the `|` character. | `list(string)` | n/a | yes |
| logs\_metrics\_categories | Metrics categories to send to destinations. | `list(string)` | `null` | no |
| name\_prefix | Optional prefix for the generated name | `string` | `""` | no |
| name\_suffix | Optional suffix for the generated name | `string` | `""` | no |
| outbound\_network\_restriction\_enabled | Whether outbound network traffic is restricted for this server | `bool` | `false` | no |
| point\_in\_time\_backup\_interval\_in\_hours | The hours between each differential backup. This is only applicable to live databases but not dropped databases. Value has to be 12 or 24. Defaults to 12 hours. | `number` | `12` | no |
| point\_in\_time\_restore\_retention\_days | Point In Time Restore configuration. Value has to be between `7` and `35` | `number` | `7` | no |
| public\_network\_access\_enabled | True to allow public network access for this server | `bool` | `false` | no |
| resource\_group\_name | Resource group name | `string` | n/a | yes |
| security\_storage\_account\_access\_key | Storage Account access key used to store security logs and reports | `string` | `null` | no |
| security\_storage\_account\_blob\_endpoint | Storage Account blob endpoint used to store security logs and reports | `string` | `null` | no |
| security\_storage\_account\_container\_name | Storage Account container name where to store SQL Server vulneralibility assessment | `string` | `null` | no |
| server\_custom\_name | Name of the SQL Server, generated if not set. | `string` | `""` | no |
| server\_extra\_tags | Extra tags to add on SQL Server or ElasticPool | `map(string)` | `{}` | no |
| server\_version | Version of the SQL Server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). See https://www.terraform.io/docs/providers/azurerm/r/sql_server.html#version | `string` | `"12.0"` | no |
| single\_databases\_sku\_name | Specifies the name of the SKU used by the database. For example, `GP_S_Gen5_2`, `HS_Gen4_1`, `BC_Gen5_2`. Use only if `elastic_pool_enabled` variable is set to `false`. More documentation [here](https://docs.microsoft.com/en-us/azure/azure-sql/database/service-tiers-general-purpose-business-critical) | `string` | `"GP_Gen5_2"` | no |
| sql\_server\_extended\_auditing\_enabled | True to enable extended auditing for SQL Server | `bool` | `false` | no |
| sql\_server\_extended\_auditing\_retention\_days | Server extended auditing logs retention | `number` | `30` | no |
| sql\_server\_security\_alerting\_enabled | True to enable security alerting for this SQL Server | `bool` | `false` | no |
| sql\_server\_vulnerability\_assessment\_enabled | True to enable vulnerability assessment for this SQL Server | `bool` | `false` | no |
| stack | Project stack name | `string` | n/a | yes |
| threat\_detection\_policy\_disabled\_alerts | Specifies a list of alerts which should be disabled. Possible values include `Access_Anomaly`, `Sql_Injection` and `Sql_Injection_Vulnerability` | `list(string)` | `[]` | no |
| threat\_detection\_policy\_enabled | True to enable thread detection policy on the databases | `bool` | `false` | no |
| threat\_detection\_policy\_retention\_days | Specifies the number of days to keep in the Threat Detection audit logs | `number` | `7` | no |
| tls\_minimum\_version | The TLS minimum version for all SQL Database associated with the server. Valid values are: `1.0`, `1.1` and `1.2`. | `string` | `"1.2"` | no |
| use\_caf\_naming | Use the Azure CAF naming provider to generate default resource name. `server_custom_name` and `elastic_pool_custom_name` override this if set. Legacy default name is used if this is set to `false`. | `bool` | `true` | no |
| use\_caf\_naming\_for\_databases | Use the Azure CAF naming provider to generate databases names. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| custom\_databases\_users | Map of the custom SQL Databases users |
| custom\_databases\_users\_roles | Map of the custom SQL Databases users roles |
| default\_administrator\_databases\_connection\_strings | Map of the SQL Databases with administrator credentials connection strings |
| default\_databases\_users | Map of the SQL Databases dedicated users |
| identity | Identity block with principal ID and tenant ID used for this SQL Server |
| security\_alert\_policy\_id | ID of the MS SQL Server Security Alert Policy |
| sql\_administrator\_login | SQL Administrator login |
| sql\_administrator\_password | SQL Administrator password |
| sql\_databases | SQL Databases |
| sql\_databases\_id | Map of the SQL Databases IDs |
| sql\_elastic\_pool | SQL Elastic Pool |
| sql\_elastic\_pool\_id | ID of the SQL Elastic Pool |
| sql\_server | SQL Server |
| terraform\_module | Information about this Terraform module |
| vulnerability\_assessment\_id | ID of the MS SQL Server Vulnerability Assessment |
<!-- END_TF_DOCS -->
## Related documentation

Microsoft Azure root documentation: [docs.microsoft.com/en-us/azure/sql-database/](https://docs.microsoft.com/en-us/azure/sql-database/)
