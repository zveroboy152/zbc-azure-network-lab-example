resource "azurerm_resource_group" "network" {
  name     = var.network_resource_group_name
  location = var.resource_group_location
  tags     = var.tags
}

resource "azurerm_virtual_network" "uswest3" {
  name                = var.uswest3_vnet_name
  address_space       = [var.uswest3_vnet_address_space]
  location            = var.uswest3_location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.tags
}

resource "azurerm_subnet" "uswest3_default" {
  name                 = "default"
  address_prefixes     = [var.uswest3_default_subnet_prefix]
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.uswest3.name
}

resource "azurerm_subnet" "uswest3_vm" {
  name                 = "vm-subnet"
  address_prefixes     = [var.uswest3_vm_subnet_prefix]
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.uswest3.name
}

resource "azurerm_subnet" "uswest3_firewall" {
  name                 = "AzureFirewallSubnet"
  address_prefixes     = [var.uswest3_firewall_subnet_prefix]
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.uswest3.name
}

resource "azurerm_subnet" "uswest3_firewall_mgmt" {
  name                 = "AzureFirewallManagementSubnet"
  address_prefixes     = [var.uswest3_firewall_mgmt_subnet_prefix]
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.uswest3.name
}

resource "azurerm_virtual_network" "uswest1" {
  name                = var.uswest1_vnet_name
  address_space       = [var.uswest1_vnet_address_space]
  location            = var.uswest1_location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.tags
}

resource "azurerm_subnet" "uswest1_gateway" {
  name                 = "GatewaySubnet"
  address_prefixes     = [var.uswest1_gateway_subnet_prefix]
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.uswest1.name
}

resource "azurerm_subnet" "uswest1_vm" {
  name                 = "vm-subnet"
  address_prefixes     = [var.uswest1_vm_subnet_prefix]
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.uswest1.name
}

resource "azurerm_virtual_network_peering" "uswest1_to_uswest3" {
  name                         = "uswest1-to-uswest3"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.uswest1.name
  remote_virtual_network_id    = azurerm_virtual_network.uswest3.id
  allow_gateway_transit        = true
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "uswest3_to_uswest1" {
  name                         = "uswest3-to-uswest1"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.uswest3.name
  remote_virtual_network_id    = azurerm_virtual_network.uswest1.id
  use_remote_gateways          = true
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_public_ip" "vpn" {
  name                = var.vpn_gateway_public_ip_name
  resource_group_name = azurerm_resource_group.network.name
  location            = var.uswest1_location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "vpn" {
  name                = var.vpn_gateway_name
  location            = var.uswest1_location
  resource_group_name = azurerm_resource_group.network.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = var.vpn_gateway_sku
  active_active       = false
  tags                = var.tags

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.uswest1_gateway.id
  }
}

resource "azurerm_public_ip" "uswest3_firewall" {
  name                = var.uswest3_firewall_public_ip_name
  resource_group_name = azurerm_resource_group.network.name
  location            = var.uswest3_location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_public_ip" "uswest3_firewall_mgmt" {
  name                = var.uswest3_firewall_mgmt_public_ip_name
  resource_group_name = azurerm_resource_group.network.name
  location            = var.uswest3_location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall" "uswest3_firewall" {
  name                = var.uswest3_firewall_name
  location            = var.uswest3_location
  resource_group_name = azurerm_resource_group.network.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Basic"
  firewall_policy_id  = azurerm_firewall_policy.uswest3.id
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.uswest3_firewall.id
    public_ip_address_id = azurerm_public_ip.uswest3_firewall.id
  }

  management_ip_configuration {
    name                 = "management"
    subnet_id            = azurerm_subnet.uswest3_firewall_mgmt.id
    public_ip_address_id = azurerm_public_ip.uswest3_firewall_mgmt.id
  }
}

resource "azurerm_firewall_policy" "uswest3" {
  name                     = var.uswest3_firewall_policy_name
  resource_group_name      = azurerm_resource_group.network.name
  location                 = var.uswest3_location
  sku                      = "Basic"
  threat_intelligence_mode = "Alert"
  tags                     = var.tags
}

resource "azurerm_route_table" "uswest3_default" {
  name                          = var.uswest3_route_table_name
  location                      = var.uswest3_location
  resource_group_name           = azurerm_resource_group.network.name
  bgp_route_propagation_enabled = true
  tags                          = var.tags
}

resource "azurerm_route" "uswest3_default_to_firewall" {
  name                   = "default-to-firewall"
  resource_group_name    = azurerm_resource_group.network.name
  route_table_name       = azurerm_route_table.uswest3_default.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.uswest3_firewall.ip_configuration[0].private_ip_address
}

resource "azurerm_route" "uswest3_onprem_via_vpngw" {
  name                = "onprem-via-vpngw"
  resource_group_name = azurerm_resource_group.network.name
  route_table_name    = azurerm_route_table.uswest3_default.name
  address_prefix      = var.local_network_gateway_address_spaces[0]
  next_hop_type       = "VirtualNetworkGateway"
}

resource "azurerm_subnet_route_table_association" "uswest3_default" {
  subnet_id      = azurerm_subnet.uswest3_default.id
  route_table_id = azurerm_route_table.uswest3_default.id
}

resource "azurerm_subnet_route_table_association" "uswest3_vm" {
  subnet_id      = azurerm_subnet.uswest3_vm.id
  route_table_id = azurerm_route_table.uswest3_default.id
}

resource "azurerm_local_network_gateway" "onprem" {
  name                = var.local_network_gateway_name
  location            = var.uswest1_location
  resource_group_name = azurerm_resource_group.network.name
  gateway_address     = var.local_network_gateway_public_ip
  address_space       = var.local_network_gateway_address_spaces
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway_connection" "s2s" {
  name                       = var.vpn_connection_name
  location                   = var.uswest1_location
  resource_group_name        = azurerm_resource_group.network.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem.id
  shared_key                 = var.vpn_connection_shared_key
  tags                       = var.tags
}
