variable "alerting_email_addresses" {
  description = "List of email addresses to send reports for threat detection and vulnerability assessment."
  type        = list(string)
  default     = []
}

variable "threat_detection_policy_enabled" {
  description = "True to enable thread detection policy on the databases."
  type        = bool
  default     = false
}

variable "threat_detection_policy_retention_days" {
  description = "Specifies the number of days to keep in the Threat Detection audit logs."
  type        = number
  default     = 7
}

variable "threat_detection_policy_disabled_alerts" {
  description = "Specifies a list of alerts which should be disabled. Possible values include `Access_Anomaly`, `Sql_Injection` and `Sql_Injection_Vulnerability`."
  type        = list(string)
  default     = []
}

variable "express_vulnerability_assessment_enabled" {
  description = "True to enable express vulnerability assessment for this SQL Server."
  type        = bool
  default     = false
}

variable "sql_server_vulnerability_assessment_enabled" {
  description = "True to enable classic vulnerability assessment for this SQL Server."
  type        = bool
  default     = false
}

variable "databases_extended_auditing_enabled" {
  description = "True to enable extended auditing for SQL databases."
  type        = bool
  default     = false
}

variable "sql_server_extended_auditing_enabled" {
  description = "True to enable extended auditing for SQL Server."
  type        = bool
  default     = false
}

variable "sql_server_security_alerting_enabled" {
  description = "True to enable security alerting for this SQL Server."
  type        = bool
  default     = false
}

variable "sql_server_extended_auditing_retention_days" {
  description = "Server extended auditing logs retention."
  type        = number
  default     = 30
}

variable "databases_extended_auditing_retention_days" {
  description = "Databases extended auditing logs retention."
  type        = number
  default     = 30
}
