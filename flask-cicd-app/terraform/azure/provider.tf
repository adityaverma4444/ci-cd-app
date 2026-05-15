terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
  }
}

provider "azurerm" {
  features {}
  # We don't have an Azure subscription wired up, so we keep this for
  # interview-only reference. To actually run plan/apply you'd:
  #   1. az login
  #   2. terraform init
  #   3. terraform plan
}
