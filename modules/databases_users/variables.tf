variable "database_name" {
  description = "Name of the database where the custom user should be created"
  type        = string
}

variable "user_name" {
  description = "Name of the custom user"
  type        = string
}

variable "user_roles" {
  description = "List of databases roles for the custom user"
  type        = list(string)
}

variable "administrator_login" {
  description = "Login for the SQL Server administrator"
  type        = string
}

variable "administrator_password" {
  description = "Password for the SQL Server administrator"
  type        = string
}

variable "sql_server_hostname" {
  description = "FQDN of the SQL Server."
  type        = string
}
