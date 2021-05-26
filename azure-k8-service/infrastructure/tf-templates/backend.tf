terraform {
  backend "azurerm" {
      key = "aksinfra.tfstate"
  }
}