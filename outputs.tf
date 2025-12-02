output "rg_name" {
  value = azurerm_resource_group.rg.name
}
output "ai_foundry_endpoint" {
  value = azapi_resource.ai_foundry.id
}
