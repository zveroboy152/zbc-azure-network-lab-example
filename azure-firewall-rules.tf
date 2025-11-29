resource "azurerm_firewall_policy_rule_collection_group" "uswest3_allow_outbound" {
  name               = "allow-outbound"
  priority           = 100
  firewall_policy_id = azurerm_firewall_policy.uswest3.id

  network_rule_collection {
    name     = "allow-all-vnet-out"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "All-out-uswest3"
      source_addresses      = [azurerm_virtual_network.uswest3.address_space[0]]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
      protocols             = ["Any"]
    }

    rule {
      name                  = "All-out-uswest1"
      source_addresses      = [azurerm_virtual_network.uswest1.address_space[0]]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
      protocols             = ["Any"]
    }
  }
}
