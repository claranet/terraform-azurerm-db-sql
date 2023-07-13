# MS SQL Server database users creation module

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

More details are available in the [CONTRIBUTING.md](../../CONTRIBUTING.md#pull-request-process) file.

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
  create_databases_users = false

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
  ]
}

module "users" {
  for_each = {
    "app-db1" = {
      name     = "app"
      database = "db1"
      roles    = ["db_accessadmin", "db_securityadmin"]
    }
  }

  source  = "claranet/db-sql/azurerm//modules/databases_users"
  version = "x.x.x"

  administrator_login    = "adminsqltest"
  administrator_password = random_password.admin_password.result

  sql_server_hostname = module.sql_single.sql_databases["db1"].fully_qualified_domain_name

  database_name = each.value.database
  user_name     = each.value.name
  user_roles    = each.value.roles
}
```

## Providers

| Name | Version |
|------|---------|
| mssql | >= 0.2.5 |
| random | >= 3.4.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [mssql_login.custom_sql_login](https://registry.terraform.io/providers/betr-io/mssql/latest/docs/resources/login) | resource |
| [mssql_user.custom_sql_user](https://registry.terraform.io/providers/betr-io/mssql/latest/docs/resources/user) | resource |
| [random_password.custom_user_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| administrator\_login | Login for the SQL Server administrator | `string` | n/a | yes |
| administrator\_password | Password for the SQL Server administrator | `string` | n/a | yes |
| database\_name | Name of the database where the custom user should be created | `string` | n/a | yes |
| sql\_server\_hostname | FQDN of the SQL Server. | `string` | n/a | yes |
| user\_name | Name of the custom user | `string` | n/a | yes |
| user\_roles | List of databases roles for the custom user | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| database\_user\_name | Name of the custom user |
| database\_user\_password | Password of the custom user |
| database\_user\_roles | Roles of the custom user |
<!-- END_TF_DOCS -->
