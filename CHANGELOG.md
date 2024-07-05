## 7.11.0 (2024-07-05)


### Features

* **AZ-1434:** add collation elastic pool db c73aa63


### Miscellaneous Chores

* **deps:** update dependency tflint to v0.51.2 df311d5
* **deps:** update dependency trivy to v0.53.0 d8f5af0

## 7.10.0 (2024-06-21)


### Features

* **AZ-1426:** add parameters for elastic and single databases 4d3376a


### Miscellaneous Chores

* **deps:** update dependency trivy to v0.52.2 b691eb7
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.92.0 3ce3620

## 7.9.0 (2024-06-14)


### Features

* add hyperscale tier support for elastic pool b2ca9f8


### Miscellaneous Chores

* **deps:** update dependency trivy to v0.52.1 875e687

## 7.8.0 (2024-06-07)


### Features

* optional max_size_gb for databases configuration e11be1b


### Miscellaneous Chores

* **deps:** update dependency opentofu to v1.7.0 4a3997e
* **deps:** update dependency opentofu to v1.7.1 638f40e
* **deps:** update dependency opentofu to v1.7.2 736d4a7
* **deps:** update dependency pre-commit to v3.7.1 836d380
* **deps:** update dependency terraform-docs to v0.18.0 15278e3
* **deps:** update dependency tflint to v0.51.0 3a82ce1
* **deps:** update dependency tflint to v0.51.1 9f0ee2f
* **deps:** update dependency trivy to v0.51.0 f7fee1a
* **deps:** update dependency trivy to v0.51.1 38f6178
* **deps:** update dependency trivy to v0.51.2 819cdbb
* **deps:** update dependency trivy to v0.51.4 1ec4e37
* **deps:** update dependency trivy to v0.52.0 ef812ab

## 7.7.2 (2024-04-26)


### Styles

* **output:** remove unused version from outputs-module 9cb5fd6


### Continuous Integration

* **AZ-1391:** enable semantic-release [skip ci] 4181b16
* **AZ-1391:** update semantic-release config [skip ci] 9538279


### Miscellaneous Chores

* **deps:** add renovate.json 0418ae5
* **deps:** enable automerge on renovate 84ab1a1
* **deps:** update dependency trivy to v0.50.2 0817d82
* **deps:** update dependency trivy to v0.50.4 67e261e
* **deps:** update renovate.json 468ca2d
* **pre-commit:** update commitlint hook 5e6cb47
* **release:** remove legacy `VERSION` file bc29a21

# v7.7.1 - 2024-01-12

Fixed
  * AZ-1304: Terraform lint fixes

# v7.7.0 - 2024-01-05

Added
 * AZ-1304: Add `family` possible parameter to `elastic_pool_sku` variable. Fixes [GITHUB-4](https://github.com/claranet/terraform-azurerm-db-sql/issues/4)

# v7.6.0 - 2023-12-01

Added
  * AZ-1260: Add `sku_name` on `databases`

# v7.5.0 - 2023-10-27

Breaking
  * AZ-1226: Changed virtual network rule resource name (deprecation) in anticipation of AzureRM provider v4.0

# v7.4.0 - 2023-10-20

Breaking
  * AZ-1210: Remove `retention_days` parameters, it must be handled at destination level now. (for reference: [Provider issue](https://github.com/hashicorp/terraform-provider-azurerm/issues/23051))

# v7.3.0 - 2023-10-13

Added
  * AZ-1204: Add `backup_interval_in_hours` on `short_term_retention parameter`

# v7.2.5 - 2023-07-13

Fixed
  * AZ-1113: Update sub-modules READMEs (according to their example)

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
