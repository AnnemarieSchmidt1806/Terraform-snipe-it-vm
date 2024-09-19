variable "resource_group_location" {
    type = string
    default = "germanywestcentral"
    description = "Location of the resource group."
}

variable "resource_group_name" {
  type = string
  default = "rg-snipeit-prod-gwc-001"
  description = "Name of the resource group"
}

variable "username" {
    type = string
    description = "The username for the local account that will be created on the new VM"
    default = "snipeit"
  
}

variable "front_door_sku_name" {
  type        = string
  description = "The SKU for the Front Door profile. Possible values include: Standard_AzureFrontDoor, Premium_AzureFrontDoor"
  default     = "Standard_AzureFrontDoor"
  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.front_door_sku_name)
    error_message = "The SKU value must be one of the following: Standard_AzureFrontDoor, Premium_AzureFrontDoor."
  }
}