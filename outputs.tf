output "virtual_network_ids" {
  description = "IDs of the provisioned virtual networks."
  value = {
    uswest3 = azurerm_virtual_network.uswest3.id
    uswest1 = azurerm_virtual_network.uswest1.id
  }
}

output "vpn_gateway_id" {
  description = "Resource ID for the VPN gateway."
  value       = azurerm_virtual_network_gateway.vpn.id
}

output "vpn_gateway_public_ip" {
  description = "Allocated public IP address for the VPN gateway."
  value       = azurerm_public_ip.vpn.ip_address
}
