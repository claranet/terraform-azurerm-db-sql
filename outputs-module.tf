output "terraform_module" {
  description = "Information about this Terraform module"
  value = {
    name       = "db-sql"
    version    = file("${path.module}/VERSION")
    provider   = "azurerm"
    maintainer = "claranet"
  }
}
