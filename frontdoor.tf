locals {
  front_door_profile_name      = "FrontDoor-prod-gwc"
  front_door_endpoint_name     = "afd-endpoint-prod-gwc"
  front_door_origin_group_name = "OriginGroup-prod-gwc"
  front_door_origin_name       = "AppServiceOrigin-prod-gwc"
  front_door_route_name        = "Route-prod-gwc"
}

resource "azurerm_cdn_frontdoor_profile" "my_front_door" {
  name                = local.front_door_profile_name
  resource_group_name = var.resource_group_name
  sku_name            = var.front_door_sku_name
}

resource "azurerm_cdn_frontdoor_endpoint" "my_endpoint" {
  name                     = local.front_door_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
}

resource "azurerm_cdn_frontdoor_origin_group" "my_origin_group" {
  name                     = local.front_door_origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
  session_affinity_enabled = true

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "my_app_service_origin" {
  name                          = local.front_door_origin_name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.my_origin_group.id

  enabled                        = true
  host_name                      = azurerm_public_ip.my_terraform_public_ip.ip_address
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = azurerm_cdn_frontdoor_endpoint.my_endpoint.host_name
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_route" "my_route" {
  name                          = local.front_door_route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.my_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.my_origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.my_app_service_origin.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpOnly"
  link_to_default_domain = true
  https_redirect_enabled = true

  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.my_custom_domain.id]
}


# ----------------------------------------
#               Domain
# ----------------------------------------

resource "azurerm_cdn_frontdoor_custom_domain" "my_custom_domain" {
  name = "snipeit-thinkport-cloud-981c"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
  host_name = "snipeit.thinkport.cloud"
  dns_zone_id = "/subscriptions/080de799-5cb1-4d45-8a10-0e2d51dd08b8/resourceGroups/rg-thinkport-cloud-domain/providers/Microsoft.Network/dnsZones/thinkport.cloud"

  tls {
    certificate_type = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
  
}

output "dns_validation_token" {
  value = azurerm_cdn_frontdoor_custom_domain.my_custom_domain.validation_token
  }

import {
  to = azurerm_cdn_frontdoor_custom_domain.my_custom_domain
  id = "/subscriptions/080de799-5cb1-4d45-8a10-0e2d51dd08b8/resourceGroups/rg-snipeit-prod-gwc-001/providers/Microsoft.Cdn/profiles/FrontDoor-prod-gwc/customDomains/snipeit-thinkport-cloud-981c"
}