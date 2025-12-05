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

output "apim_private_endpoint_ip" {
  value = azurerm_private_endpoint.apim_pe.private_service_connection[0].private_ip_address
}

output "apim_name" {
  value = azurerm_api_management.apim.name
}
