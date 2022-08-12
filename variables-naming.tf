variable "name_prefix" {
  description = "Optional prefix for the generated name"
  type        = string
  default     = ""
}

variable "server_custom_name" {
  description = "Name of the SQL Server, generated if not set."
  type        = string
  default     = ""
}

variable "elastic_pool_custom_name" {
  description = "Name of the SQL Elastic Pool, generated if not set."
  type        = string
  default     = ""
}
