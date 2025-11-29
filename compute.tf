resource "azurerm_network_interface" "uswest3_vm" {
  name                = var.uswest3_vm_nic_name
  location            = var.uswest3_location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.uswest3_vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "uswest3_vm" {
  name                            = var.uswest3_vm_name
  resource_group_name             = azurerm_resource_group.network.name
  location                        = var.uswest3_location
  size                            = var.uswest3_vm_size
  priority                        = "Spot"
  eviction_policy                 = "Deallocate"
  max_bid_price                   = -1
  admin_username                  = var.uswest3_vm_admin_username
  admin_password                  = var.uswest3_vm_admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.uswest3_vm.id]
  tags                            = var.tags

  os_disk {
    name                 = "${var.uswest3_vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "uswest1_vm" {
  name                = var.uswest1_vm_nic_name
  location            = var.uswest1_location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.uswest1_vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "uswest1_vm" {
  name                            = var.uswest1_vm_name
  resource_group_name             = azurerm_resource_group.network.name
  location                        = var.uswest1_location
  size                            = var.uswest1_vm_size
  priority                        = "Spot"
  eviction_policy                 = "Deallocate"
  max_bid_price                   = -1
  admin_username                  = var.uswest1_vm_admin_username
  admin_password                  = var.uswest1_vm_admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.uswest1_vm.id]
  tags                            = var.tags

  os_disk {
    name                 = "${var.uswest1_vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

