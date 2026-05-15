resource "azurerm_resource_group" "flask_rg" {
  name     = "rg-flask-cicd-prod"
  location = "centralindia"

  tags = {
    project = "flask-cicd-app"
    owner   = "aditya"
    stage   = "17-terraform"
  }
}

# A Resource Group is Azure's "folder" for related resources.
# It controls billing, permissions, and lifecycle (delete RG = delete everything inside).
