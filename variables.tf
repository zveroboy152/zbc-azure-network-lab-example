variable "subscription_id" {
  description = "Azure subscription to deploy into."
  type        = string
}

variable "network_resource_group_name" {
  description = "Resource group to hold all networking assets."
  type        = string
}

variable "resource_group_location" {
  description = "Azure location for the resource group metadata."
  type        = string
}

variable "uswest3_vnet_name" {
  description = "Name of the US West 3 virtual network."
  type        = string
}

variable "uswest3_vnet_address_space" {
  description = "CIDR for the US West 3 virtual network."
  type        = string
}

variable "uswest3_location" {
  description = "Azure region for the US West 3 virtual network."
  type        = string
}

variable "uswest3_default_subnet_prefix" {
  description = "CIDR for the default subnet in the US West 3 VNet."
  type        = string
}

variable "uswest3_vm_subnet_prefix" {
  description = "CIDR for the VM subnet in the US West 3 VNet."
  type        = string
}

variable "uswest1_vnet_name" {
  description = "Name of the US West 1 virtual network."
  type        = string
}

variable "uswest1_vnet_address_space" {
  description = "CIDR for the US West 1 virtual network."
  type        = string
}

variable "uswest1_location" {
  description = "Azure region for the US West 1 virtual network."
  type        = string
}

variable "uswest1_gateway_subnet_prefix" {
  description = "CIDR block carved from the West 1 VNet for the VPN Gateway subnet."
  type        = string
}

variable "uswest1_vm_subnet_prefix" {
  description = "CIDR for the VM subnet in the US West 1 VNet."
  type        = string
}

variable "uswest1_vm_name" {
  description = "Name of the US West 1 virtual machine."
  type        = string
}

variable "uswest1_vm_nic_name" {
  description = "Name of the NIC for the US West 1 virtual machine."
  type        = string
}

variable "uswest1_vm_size" {
  description = "SKU/size for the US West 1 virtual machine."
  type        = string
  default     = "Standard_D2as_v5"
}

variable "uswest1_vm_admin_username" {
  description = "Admin username for the US West 1 virtual machine."
  type        = string
  default     = "zbc-admin"
}

variable "uswest1_vm_admin_password" {
  description = "Admin password for the US West 1 virtual machine."
  type        = string
  sensitive   = true
}

variable "vpn_gateway_name" {
  description = "Name of the VPN gateway resource."
  type        = string
}

variable "vpn_gateway_public_ip_name" {
  description = "Name for the VPN gateway public IP resource."
  type        = string
}

variable "vpn_gateway_sku" {
  description = "Azure VPN gateway SKU (e.g. VpnGw1)."
  type        = string
  default     = "VpnGw1"
}

variable "local_network_gateway_name" {
  description = "Name of the on-premises local network gateway."
  type        = string
}

variable "local_network_gateway_public_ip" {
  description = "Public IP address of the on-premises VPN device."
  type        = string
}

variable "local_network_gateway_address_spaces" {
  description = "Address spaces for the on-premises network reachable over the S2S VPN."
  type        = list(string)
}

variable "vpn_connection_name" {
  description = "Name of the site-to-site VPN connection."
  type        = string
}

variable "vpn_connection_shared_key" {
  description = "Shared key for the site-to-site VPN connection."
  type        = string
  sensitive   = true
}

variable "uswest3_vm_name" {
  description = "Name of the US West 3 virtual machine."
  type        = string
}

variable "uswest3_vm_nic_name" {
  description = "Name of the network interface for the US West 3 VM."
  type        = string
}

variable "uswest3_vm_size" {
  description = "SKU/size for the US West 3 VM."
  type        = string
  default     = "Standard_B1ms"
}

variable "uswest3_vm_admin_username" {
  description = "Admin username for the US West 3 VM."
  type        = string
  default     = "zbc-admin"
}

variable "uswest3_vm_admin_password" {
  description = "Admin password for the US West 3 VM."
  type        = string
  sensitive   = true
}

variable "uswest3_firewall_subnet_prefix" {
  description = "CIDR for the Azure Firewall subnet (must be /26 or larger) in the US West 3 VNet."
  type        = string
}

variable "uswest3_firewall_name" {
  description = "Name of the Azure Firewall in US West 3."
  type        = string
}

variable "uswest3_firewall_policy_name" {
  description = "Name of the Azure Firewall Policy for the US West 3 firewall."
  type        = string
}

variable "uswest3_firewall_mgmt_subnet_prefix" {
  description = "CIDR for the Azure Firewall management subnet (must be /26 or larger) in the US West 3 VNet."
  type        = string
}

variable "uswest3_firewall_public_ip_name" {
  description = "Name of the public IP for the Azure Firewall in US West 3."
  type        = string
}

variable "uswest3_firewall_mgmt_public_ip_name" {
  description = "Name of the management public IP for the Azure Firewall Basic SKU in US West 3."
  type        = string
}

variable "uswest3_route_table_name" {
  description = "Name of the route table for US West 3 subnets defaulting to the firewall."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}
