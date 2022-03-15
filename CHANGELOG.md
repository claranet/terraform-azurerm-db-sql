# Unreleased

Added
  * AZ-615: Add an option to enable or disable default tags

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
