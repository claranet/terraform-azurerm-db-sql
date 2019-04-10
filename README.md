# Azure SQL Database

## Purpose
This Terraform module creates an [Azure SQL Server](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-servers) 
and associated databases in an [SQL Elastic Pool](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-elastic-pool) 
with [DTU purchasing model](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-service-tiers-dtu) 
only and [Diagnostic settings](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-metrics-diag-logging) 
enabled.

The [vCore-based model](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-service-tiers-vcore)
is not available.

## Usage
You can use this module by including it this way:
```hcl
module "az-region" {
  source = "git::ssh://git@git.fr.clara.net/claranet/cloudnative/projects/cloud/azure/terraform/modules/regions.git?ref=vX.X.X"

  azure_region = "${var.azure_region}"
}

module "rg" {
  source = "git::ssh://git@git.fr.clara.net/claranet/cloudnative/projects/cloud/azure/terraform/modules/rg.git?ref=vX.X.X"

  azure_region = "${module.az-region.location}"
  client_name  = "${var.client_name}"
  environment  = "${var.environment}"
  stack        = "${var.stack}"
}

module "sql" {
  source = "git::ssh://git@git.fr.clara.net/claranet/cloudnative/projects/cloud/azure/terraform/features/db-sql.git?ref=vX.X.X"

  client_name         = "${var.client_name}"
  environment         = "${var.environment}"
  location            = "${module.az-region.location}"
  location_short      = "${module.az-region.location-short}"
  resource_group_name = "${module.rg.resource_group_name}"
  stack               = "${var.stack}"

  databases_names = ["users", "documents"]

  administrator_login    = "claranet"
  administrator_password = "${var.sql_admin_password}"

  sku_tier     = "Standard"
  sku_capacity = "100"

  elastic_pool_max_size = "50"

  logs_storage_account_name = "${data.terraform_remote_state.run.logs_storage_account_name}"
  logs_storage_account_rg   = "${data.terraform_remote_state.run.resource_group_name}"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| administrator\_login | Administrator login for SQL Server | string | n/a | yes |
| administrator\_password | Administrator password for SQL Server | string | n/a | yes |
| client\_name |  | string | n/a | yes |
| database\_max\_dtu\_capacity | The maximum capacity any one database can consume in the Elastic Pool. Default to the max Elastic Pool capacity. | string | `""` | no |
| database\_min\_dtu\_capacity | The minimum capacity all databases are guaranteed in the Elastic Pool. Defaults to 0. | string | `"0"` | no |
| databases\_collation | SQL Collation for the databases | string | `"SQL_LATIN1_GENERAL_CP1_CI_AS"` | no |
| databases\_extra\_tags | Extra tags to add on the SQL databases | map | `<map>` | no |
| databases\_names | Names of the databases to create for this server | list | n/a | yes |
| elastic\_pool\_custom\_name | Name of the SQL Elastic Pool, generated if not set. | string | `""` | no |
| elastic\_pool\_extra\_tags | Extra tags to add on the SQL Elastic Pool | map | `<map>` | no |
| elastic\_pool\_max\_size | Maximum size of the Elastic Pool in gigabytes | string | n/a | yes |
| environment |  | string | n/a | yes |
| extra\_tags | Extra tags to add | map | `<map>` | no |
| location | Azure location for SQL Server. | string | n/a | yes |
| location\_short | Short string for Azure location. | string | n/a | yes |
| logs\_retention | Retention in days for databases logs on Storage Account | string | `"30"` | no |
| logs\_storage\_account\_name | Storage Account name for databases logs | string | n/a | yes |
| logs\_storage\_account\_rg | Storage Account Resource Group name for databases logs | string | n/a | yes |
| name\_prefix | Optional prefix for the generated name | string | `""` | no |
| resource\_group\_name |  | string | n/a | yes |
| server\_custom\_name | Name of the SQL Server, generated if not set. | string | `""` | no |
| server\_extra\_tags | Extra tags to add on SQL Server | map | `<map>` | no |
| sku\_capacity | SKU capacity (eDTUs) for the Elastic Pool. See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-dtu-resource-limits-elastic-pools | string | n/a | yes |
| sku\_tier | SKU tier for the Elastic Pool. Premium tier with zone redundancy is mandatory for high availability. Possible values are "Basic", "Standard", or "Premium". | string | n/a | yes |
| stack |  | string | n/a | yes |
| version | Versio of the SQL Server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). See https://www.terraform.io/docs/providers/azurerm/r/sql_server.html#version | string | `"12.0"` | no |
| zone\_redundant | Whether or not the Elastic Pool is zone redundant, SKU tier must be Premium to use it. This is mandatory for high availability. | string | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| sql\_databases\_creation\_date | Creation date of the SQL Databases |
| sql\_databases\_default\_secondary\_location | The default secondary location of the SQL Databases |
| sql\_databases\_id | Id of the SQL Databases |
| sql\_elastic\_pool\_id | Id of the SQL Elastic Pool |
| sql\_server\_fqdn | Fully qualified domain name of the SQL Server |
| sql\_server\_id | Id of the SQL Server |

## Related documentation
Terraform SQL Server documentation: [https://www.terraform.io/docs/providers/azurerm/r/sql_server.html]

Terraform SQL Database documentation: [https://www.terraform.io/docs/providers/azurerm/r/sql_database.html]

Terraform SQL Elastic Pool documentation: [https://www.terraform.io/docs/providers/azurerm/r/mssql_elasticpool.html]

Microsoft Azure root documentation: [https://docs.microsoft.com/en-us/azure/sql-database/]
