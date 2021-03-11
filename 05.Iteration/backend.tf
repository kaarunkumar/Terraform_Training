terraform {
  backend "azurerm" {
    resource_group_name  = "terrafromstateakrg"
    storage_account_name = "terraformstateaksa"
    container_name       = "tfstate"
    key                  = "testtf.tfstate"
  }
}