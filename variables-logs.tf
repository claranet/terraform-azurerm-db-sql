variable "logs_destinations_ids" {
  type        = list(string)
  description = "List of destination resources Ids for logs diagnostics destination. Can be Storage Account, Log Analytics Workspace and Event Hub. No more than one of each can be set. Empty list to disable logging."
}

variable "logs_retention_days" {
  description = "Retention duration for logs"
  type        = number
  default     = 30
}
