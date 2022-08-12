variable "default_tags_enabled" {
  description = "Option to enable or disable default tags"
  type        = bool
  default     = true
}

variable "extra_tags" {
  description = "Extra tags to add"
  type        = map(string)
  default     = {}
}

variable "server_extra_tags" {
  description = "Extra tags to add on SQL Server or ElasticPool"
  type        = map(string)
  default     = {}
}

variable "elastic_pool_extra_tags" {
  description = "Extra tags to add on ElasticPool"
  type        = map(string)
  default     = {}
}
