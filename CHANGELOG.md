# v7.2.4 - 2023-04-26

Fixed
  * AZ-387: Fix README
  * [GH-2](https://github.com/claranet/terraform-azurerm-db-sql/pull/2): Fix databases usernames

# v7.2.3 - 2023-04-20

Fixed
  * [GH-1](https://github.com/claranet/terraform-azurerm-db-sql/pull/1): Fix default collation

# v7.2.2 - 2023-01-27

Fixed
  * AZ-988: Fix wrong `elastic_pool_sku` variable description

# v7.2.1 - 2022-12-23

Fixed
  * AZ-945: Fix bug in with loop in `r-naming.tf`

# v7.2.0 - 2022-11-25

Breaking
  * AZ-908: Implement Azure CAF naming (using Microsoft provider)

Changed
  * AZ-908: Bump `diagnostics-settings`
  * AZ-908: Rework and optimize module HCL code

# v7.1.0 - 2022-11-18

Changed
  * AZ-901: Change default value for `public_network_access_enabled` variable to `false`

Added
  * AZ-896: Adding setting for users passwords

Fixed
  * AZ-896: Fix `backup_retention` variables format

Breaking
  * AZ-896: Replace `azurerm_sql_firewall_rule` by `azurerm_mssql_firewall_rule`

# v7.0.0 - 2022-09-30

Breaking
  * AZ-840: Update to Terraform `v1.3`

Changed
  * AZ-843: Update to AzureRM `v3.0+`

# v4.4.1 - 2022-08-12

Fixed
  * AZ-400: Fix CI

# v4.4.0 - 2022-08-12

Fixed
  * AZ-387: Implement most of the `azurerm_mssql_database` resource parameters
  * AZ-387: Allow to configure specific tags per database

Breaking
  * AZ-400: Rebuild module with new resources and simplify interface
  * AZ-387: Rework user creation, replace Python and pymssql dependency by Terraform provider
  * AZ-387: Split custom users creation in a submodule
  * AZ-387: Remove Powershell dependency for db backup configuration

# v4.3.0 - 2022-07-01

Added
  * AZ-615: Add an option to enable or disable default tags
  * AZ-770: Add Terraform module info in output

Fixed
  * AZ-772: Fix deprecated terraform code with `v1.2.3`

# v4.2.1 - 2022-01-18

Fixed
  * AZ-669 : Fix long_term_retention_policy monthly_retention

# v4.2.0 - 2021-12-28

Fixed
  * AZ-636: Fix LTR retention settings for single databases

Added
  * AZ-622: Allow specifying databases license type

# v4.1.2 - 2021-11-23

Fixed
  * AZ-589: Avoid plan drift when specifying Diagnostic Settings categories
  * AZ-600: Fix variable type for retention parameters in single database

# v4.1.1 - 2021-10-19

Changed
  * AZ-570: Bump pymssql module used for users management to v2.2.2
  * AZ-572: Revamp examples and improve CI

# v4.1.0 - 2021-08-30

Breaking
  * AZ-530: Cleanup module, fix linter errors

Changed
  * AZ-532: Revamp README with latest `terraform-docs` tool

# v4.0.0 - 2021-03-10

Breaking
  * AZ-273: Use `for_each` to iterate over databases
  * AZ-160: Revamp diagnostic settings
  * AZ-351: Allow usage of vCore model
  * AZ-372: Deploy single database instead of elasticpool

Added
  * AZ-354: Allow do add vnet rules
  * AZ-362: Allow to create custom login/users with builtin roles assigned on database

Changed
  * AZ-273: Terraform 0.13+ compatible
  * AZ-398: Force lowercase on default generated name

# v2.1.2/v3.0.1 - 2020-07-29

Changed
  * AZ-243: Fix README

# v2.1.1/v3.0.0 - 2020-07-13

Changed
  * AZ-198: Update README and tag module compatible both AzureRM provider < 2.0 and >= 2.0

# v2.1.0 - 2020-03-27

Added
  * AZ-138: Allow to configure SQL Server PITR retention

Changed
  * AZ-140: Make SQL user creation idempotent
  * AZ-133: Use 3rd party logging module

# v2.0.0 - 2019-09-06

Breaking
  * AZ-94: Terraform 0.12 / HCL2 format

Added
  * AZ-107: Manage databases users creation
  * AZ-118: Add LICENSE, NOTICE & Github badges

# v1.1.0 - 2019-06-18

Changed
  * AZ-94: Rename `version` input to `server_version` for Terraform 0.12 compatibility

# v1.0.0 - 2019-05-14

Added
  * AZ-70: First version
