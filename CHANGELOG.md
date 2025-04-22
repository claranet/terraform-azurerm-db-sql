## 8.2.1 (2025-04-22)

### Bug Fixes

* 🐛 add missing primary_user_assigned_identity_id parameter required for UserAssigned identity b097db0
* 🐛 null error 55bc345

### Documentation

* 📚️ update README 0faa585
* description dot a0af195

### Miscellaneous Chores

* **deps:** update dependency trivy to v0.61.1 10e8b2e

## 8.2.0 (2025-04-18)

### Features

* **GH-3:** merge single_database and elastic_pools 3872098

### Code Refactoring

* **GH-3:** revamp module c48ad05

### Miscellaneous Chores

* moved blocks fffedf1

## 8.1.1 (2025-04-14)

### Bug Fixes

* parametrize SQL DB identity ([#9](https://git.fr.clara.net/claranet/projects/cloud/azure/terraform/modules/db-sql/issues/9)) 4169302

### Documentation

* **GH-9:** update README 9f1b77f

## 8.1.0 (2025-04-14)

### Features

* **GH-7:** add option to modify SQL server identity 08b98b1
* unhardcode SQL server identity 848122b

### Code Refactoring

* code lint 40638ab

### Miscellaneous Chores

* **deps:** update dependency pre-commit to v4.2.0 9a89513
* **deps:** update dependency terraform-docs to v0.20.0 7f33940
* **deps:** update dependency tflint to v0.55.1 1c2ea43
* **deps:** update dependency trivy to v0.59.0 6ff6f63
* **deps:** update dependency trivy to v0.59.1 f58c891
* **deps:** update dependency trivy to v0.60.0 3220d91
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.21.0 7e9b69f
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.22.0 271b542
* **deps:** update pre-commit hook tofuutils/pre-commit-opentofu to v2.2.0 5fce321
* **deps:** update terraform mssql to ~> 0.3.0 752d22c
* **deps:** update tools 54f875f
* update Github templates de4cc08

## 8.0.0 (2025-01-31)

### ⚠ BREAKING CHANGES

* **AZ-1088:** module v8 structure and updates

### Features

* **AZ-1088:** module v8 structure and updates f1bba72

### Miscellaneous Chores

* **deps:** update dependency claranet/diagnostic-settings/azurerm to v7 2dada57
* **deps:** update dependency opentofu to v1.8.3 19bcc58
* **deps:** update dependency opentofu to v1.8.4 fe9a947
* **deps:** update dependency opentofu to v1.8.6 ef69712
* **deps:** update dependency opentofu to v1.8.8 4b5f1f9
* **deps:** update dependency opentofu to v1.9.0 d26595f
* **deps:** update dependency pre-commit to v4 bc6c3ad
* **deps:** update dependency pre-commit to v4.1.0 7a36210
* **deps:** update dependency tflint to v0.54.0 6da88c5
* **deps:** update dependency tflint to v0.55.0 448f3be
* **deps:** update dependency trivy to v0.56.1 287ebc5
* **deps:** update dependency trivy to v0.56.2 dae1e99
* **deps:** update dependency trivy to v0.57.1 ec288f3
* **deps:** update dependency trivy to v0.58.1 0c83981
* **deps:** update dependency trivy to v0.58.2 c3bb0d9
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.19.0 154b211
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.20.0 6c70802
* **deps:** update pre-commit hook pre-commit/pre-commit-hooks to v5 9181a9f
* **deps:** update pre-commit hook tofuutils/pre-commit-opentofu to v2.1.0 8a6c345
* **deps:** update tools 037d46f
* **deps:** update tools 124b78d
* prepare for new examples structure 7c17e42
* update examples structure 46105cb
* update submodule READMEs with latest template 90932ed
* update tflint config for v0.55.0 52f5770

## 7.12.0 (2024-10-03)

### Features

* use Claranet "azurecaf" provider e34bdec

### Documentation

* update README badge to use OpenTofu registry 1fb419b
* update README with `terraform-docs` v0.19.0 7cfbae4

### Miscellaneous Chores

* **deps:** update dependency opentofu to v1.7.3 82ae5cd
* **deps:** update dependency opentofu to v1.8.0 a3ff664
* **deps:** update dependency opentofu to v1.8.1 8e0aec1
* **deps:** update dependency pre-commit to v3.8.0 6f0a6ac
* **deps:** update dependency tflint to v0.52.0 633cd0c
* **deps:** update dependency tflint to v0.53.0 793bc42
* **deps:** update dependency trivy to v0.54.1 1486980
* **deps:** update dependency trivy to v0.55.0 06b2d88
* **deps:** update dependency trivy to v0.55.1 687d11d
* **deps:** update dependency trivy to v0.55.2 9e4ba99
* **deps:** update dependency trivy to v0.56.0 6a62a35
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.17.0 7186fd4
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.18.0 6b50794
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.92.1 0db7dda
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.92.2 8a48961
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.92.3 98b7b4c
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.93.0 ffb830d
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.94.0 82ef21c
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.94.1 ea33d3e
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.94.3 5bdc9f4
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.95.0 2eca800
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.96.0 a77a077
* **deps:** update tools 71f83c5
* **deps:** update tools 0b3a3e4

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
