provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "root_mg" {
  display_name = "Root Management Group"
  name         = "8hours-root-mg"
}
resource "azurerm_management_group" "prod" {
  display_name = "Production"
  name         = "prod-mg"
  parent_management_group_id = azurerm_management_group.root_mg.id
}

data "azurerm_subscription" "current" {}

resource "azurerm_management_group_subscription_association" "link" {
  subscription_id         = data.azurerm_subscription.current.id
  management_group_id     = azurerm_management_group.root_mg.id
}
