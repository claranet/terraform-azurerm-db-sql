# Azure SQL Database

## Purpose
This Terraform module creates an [Azure SQL Server and Database](https://docs.microsoft.com/en-us/azure/sql-database/) 
with [Diagnostic settings](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-metrics-diag-logging) 
enabled.

## Usage
You can use this module by including it this way:
```
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

  database_name = "my_database"

  administrator_login    = "claranet"
  administrator_password = "${var.sql_admin_password}"

  database_max_size = "107374182400" # 100Gb

  database_sku = {
    tier = "Standard"
    size = "S2"
  }

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
| custom\_name | Name of the SQL Server, generated if not set. | string | `""` | no |
| database\_extra\_tags | Extra tags to add on the SQL database | map | `<map>` | no |
| database\_max\_size | Maximum size of the database in bytes | string | n/a | yes |
| database\_name | Name of the database to create for this server | string | n/a | yes |
| database\_sku | SKU for the database with tier and size. Example {tier="Standard", size="S1"} | map | n/a | yes |
| databases\_collation | SQL Collation for the database | string | `"SQL_LATIN1_GENERAL_CP1_CI_AS"` | no |
| environment |  | string | n/a | yes |
| extra\_tags | Extra tags to add | map | `<map>` | no |
| location | Azure location for App Service Plan. | string | n/a | yes |
| location\_short | Short string for Azure location. | string | n/a | yes |
| logs\_retention | Retention in days for audit logs on Storage Account | string | `"30"` | no |
| logs\_storage\_account\_name | Storage Account name for database logs | string | n/a | yes |
| logs\_storage\_account\_rg | Storage Account Resource Group name for database logs | string | n/a | yes |
| name\_prefix | Optional prefix for the generated name | string | `""` | no |
| resource\_group\_name |  | string | n/a | yes |
| server\_extra\_tags | Extra tags to add on SQL Server | map | `<map>` | no |
| stack |  | string | n/a | yes |
| version | Versio of the SQL Server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). See https://www.terraform.io/docs/providers/azurerm/r/sql_server.html#version | string | `"12.0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| sql\_database\_creation\_date | Creation date of the SQL Database |
| sql\_database\_default\_secondary\_location | The default secondary location of the SQL Database. |
| sql\_database\_id | Id of the SQL Database |
| sql\_server\_fqdn | Fully qualified domain name of the SQL Server |
| sql\_server\_id | Id of the SQL Server |

## Related documentation
Terraform SQL Server documentation: [https://www.terraform.io/docs/providers/azurerm/r/sql_server.html]

Terraform SQL Database documentation: [https://www.terraform.io/docs/providers/azurerm/r/sql_database.html]

Microsoft Azure documentation: [https://docs.microsoft.com/en-us/azure/sql-database/]
