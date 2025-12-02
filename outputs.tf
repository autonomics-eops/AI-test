output "rg_name" {
  value = azurerm_resource_group.rg.name
}
output "ai_foundry_endpoint" {
  value = azurerm_ai_foundry_workspace.foundry.id
}
