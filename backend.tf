terraform {
  
backend "azurerm" {
      resource_group_name  = "tfstate-miniproject1"
      storage_account_name = "mini11549"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }
}