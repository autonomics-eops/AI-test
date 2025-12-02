resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}
resource "azurerm_storage_account" "sa" {
  name                     = var.storage_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
resource "azapi_resource" "ai_foundry" {
  type                = "Microsoft.AI.Foundation/workspaces@2024-10-01-preview"
  name                = var.ai_foundry_name
  location            = var.location
  parent_id           = azurerm_resource_group.rg.id

  body =jsoncode({
    properties = {
      publicNetworkAccess = "Enabled"
      }
  })
}
