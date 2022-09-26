<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| mssql | >= 0.2.5 |
| random | >= 2.0 |

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
| sql\_server\_hostname | FQDN of the SQL Server | `string` | n/a | yes |
| user\_name | Name of the custom user | `string` | n/a | yes |
| user\_roles | List of databases roles for the custom user | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| database\_user\_name | Name of the custom user |
| database\_user\_password | Password of the custom user |
| database\_user\_roles | Roles of the custom user |
<!-- END_TF_DOCS -->