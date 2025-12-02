variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "location" {
  default = "eastus"
}
variable "rg_name" {
  default = "rg-ai-landingzone"
}
variable "vnet_name" {
  default = "vnet-ai"
}
variable "address_space" {
  default = ["10.10.0.0/16"]
}
variable "storage_name" {
  default = "aistoragelz123"
}
variable "ai_foundry_name" {
  default = "ai-foundry-demo"
}
