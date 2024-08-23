variable "resource_group_location" {
    type = string
    default = "germanywestcentral"
    description = "Location of the resource group."
}

variable "resource_group_name" {
  type = string
  default = "rg-snipeit-prod-gwc-001"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in Azure subscription"
}

variable "username" {
    type = string
    description = "The username for the local account that will be created on the new VM"
    default = "azureadmin"
  
}