resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name, location]
  }
}
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name, location]  # Ignore changes in name and location to avoid unnecessary updates
  }
}
resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name, address_prefixes]  # Ignore changes in subnet configuration
  }
}
resource "azurerm_storage_account" "sa" {
  name                     = var.storage_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name, location]  # Ignore changes in name and location
  }
}

resource "azapi_resource" "ai_foundry" {
  type                      = "Microsoft.CognitiveServices/accounts@2025-06-01"
  name                      = var.ai_foundry_name
  parent_id                 = azurerm_resource_group.rg.id
  location                  = var.location
  schema_validation_enabled = false

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name, location]  # Ignore changes to prevent unnecessary updates
  }

  body = {
    kind = "AIServices"
    sku = {
      name = "S0"
    }
    identity = {
      type = "SystemAssigned"
    }
    properties = {
      disableLocalAuth      = false
      allowProjectManagement = true
      customSubDomainName   = var.ai_foundry_name
    }
  }
}

resource "azapi_resource" "aifoundry_deployment_gpt_4o" {
  type      = "Microsoft.CognitiveServices/accounts/deployments@2023-05-01"
  name      = "gpt-4o"
  parent_id = azapi_resource.ai_foundry.id

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name, location]  # Ignore changes to prevent unnecessary updates
  }

  body = {
    sku = {
      name     = "GlobalStandard"
      capacity = 1
    }
    properties = {
      model = {
        format  = "OpenAI"
        name    = "gpt-4o"
        version = "2024-11-20"
      }
    }
  }

  depends_on = [
    azapi_resource.ai_foundry
  ]
}

#####################################################
# APIM Standard V2 + Private Endpoint + Private DNS
#####################################################

resource "azapi_resource" "apim" {
  type                      = "Microsoft.ApiManagement/service@2023-05-01"
  name                      = var.apim_name
  parent_id                 = azurerm_resource_group.rg.id
  location                  = var.location
  schema_validation_enabled = false

  body = {
    identity = { type = "SystemAssigned" }
    sku = { name = "Standard_V2", capacity = 1 }
    properties = {
      publisherEmail = var.apim_publisher_email
      publisherName  = var.apim_publisher_name
    }
  }

  lifecycle { prevent_destroy = true }
}

# Create a Private Endpoint for APIM gateway
resource "azapi_resource" "apim_private_endpoint" {
  type       = "Microsoft.Network/privateEndpoints@2023-02-01"
  name       = "${var.apim_name}-pe"
  parent_id  = azurerm_resource_group.rg.id
  location   = var.location

  body = {
    properties = {
      subnet = { id = azurerm_subnet.default.id }  # or another dedicated subnet
      privateLinkServiceConnections = [
        {
          name                          = "${var.apim_name}-pls"
          privateLinkServiceId          = azapi_resource.apim.id
          groupIds                      = ["gateway"]   # as per APIM Standard V2 private link docs
        }
      ]
    }
  }

  depends_on = [
    azapi_resource.apim
  ]
}

# Private DNS zone for APIM (azure-api.net)
resource "azurerm_private_dns_zone" "apim_dns" {
  name                = "azure-api.net"
  resource_group_name = azurerm_resource_group.rg.name
}

# Link DNS zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "apim_dns_link" {
  name                  = "${var.apim_name}-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.apim_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# A-record for APIM inside Private DNS zone: map FQDN to the private IP from PE
resource "azurerm_private_dns_a_record" "apim_dns_record" {
  name                = "apim"
  zone_name           = azurerm_private_dns_zone.apim_dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records = [
   jsondecode(azapi_resource.apim_private_endpoint.output).properties.networkInterfaces[0].ipConfigurations[0].privateIPAddress
  ]
}
