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
