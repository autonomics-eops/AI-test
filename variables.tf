#variable "subscription_id" {
 # type = string
#}
#variable "tenant_id" {
 # type = string
#}
#variable "client_id" {
 # type = string
#}
#variable "client_secret" {
#  type = string
#}
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
variable "apim_name" {
  type    = string
  default = "apim0-demo"
}
variable "apim_publisher_name" {
  type    = string
  default = "MyOrg"
}
variable "apim_publisher_email" {
  type    = string
  default = "akshansh.t@hcltech.com"
}
