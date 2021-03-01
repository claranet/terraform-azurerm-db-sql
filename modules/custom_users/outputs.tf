output "custom_user_name" {
  description = "Name of the custom user"
  value       = var.user_name
}

output "custom_user_password" {
  description = "password of the custom user"
  value       = random_password.custom_user_password.result
}

output "custom_user_roles" {
  description = "Roles of the custom user"
  value       = var.user_roles
}
