# Wrapper env herited vars

variable "azure_region" {
  type        = string
  description = "Azure region to use"
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription id"
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure tenant id"
}

variable "client_name" {
  type        = string
  description = "Client name/account used in naming"
}

variable "environment" {
  type        = string
  description = "Project environment"
}

variable "stack" {
  type        = string
  description = "Project stack name"
}
