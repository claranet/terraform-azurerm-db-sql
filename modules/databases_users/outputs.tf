output "name" {
  description = "Name of the custom user."
  value       = var.user_name
}

output "password" {
  description = "Password of the custom user."
  value       = random_password.main.result
  sensitive   = true
}

output "roles" {
  description = "Roles of the custom user."
  value       = var.user_roles
}
