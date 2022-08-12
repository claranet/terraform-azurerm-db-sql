output "database_user_name" {
  description = "Name of the custom user"
  value       = var.user_name
}

output "database_user_password" {
  description = "Password of the custom user"
  value       = random_password.custom_user_password.result
  sensitive   = true
}

output "database_user_roles" {
  description = "Roles of the custom user"
  value       = var.user_roles
}
