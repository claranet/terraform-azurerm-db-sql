output "terraform_module" {
  description = "Information about this Terraform module"
  value = {
    name       = "db-sql"
    provider   = "azurerm"
    maintainer = "claranet"
  }
}
