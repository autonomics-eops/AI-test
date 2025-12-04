output "rg_name" {
  value = azurerm_resource_group.rg.name
}
output "ai_foundry_endpoint" {
  value = azapi_resource.ai_foundry.id
}
output "foundry_account_id" {
  value = azapi_resource.ai_foundry.id
}

output "foundry_model_deployment_id" {
  value = azapi_resource.aifoundry_deployment_gpt_4o.id
}
