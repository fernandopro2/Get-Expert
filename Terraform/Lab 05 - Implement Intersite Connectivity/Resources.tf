resource "azurerm_resource_group" "rg1" {
  name     = "az104-05-rg1"
  location = var.resource_group_region1
}

resource "azurerm_resource_group" "rg2" {
  name     = "az104-05-rg2"
  location = var.resource_group_region2
}


/* VM Components
    - NSG
    - NSG Rules
    - vNETs
    - Subnets
    - NSGs/Subnet association
    - Public IP
    - Network Interfaces
        - IP Configuration
    - VM
        - OS Disk
        - Image

*/

# NSG (All subnets)
resource "azurerm_network_security_group" "nsg" {
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  name                = "az104-05-nsg"
}

resource "azurerm_network_security_rule" "nsrule" {
  name                        = "AllowInboundRDP"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 3389
  source_address_prefix       = "46.189.193.247"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg1.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_virtual_network" "vnet0" {
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  name                = "az104-05-vnet0"
  address_space       = ["10.50.0.0/22"]
}


resource "azurerm_virtual_network" "vnet1" {
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  name                = "az104-05-vnet1"
  address_space       = ["10.51.0.0/22"]
}


resource "azurerm_virtual_network" "vnet2" {
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  name                = "az104-05-vnet2"
  address_space       = ["10.52.0.0/22"]
}

resource "azurerm_subnet" "subnet0" {
  name                 = "Subnet0"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet0.name
  address_prefixes     = ["10.50.0.0/24"]

}

resource "azurerm_subnet" "subnet1" {
  name                 = "Subnet1"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.51.0.0/24"]

}

resource "azurerm_subnet" "subnet2" {
  name                 = "Subnet2"
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.52.0.0/24"]

}

resource "azurerm_subnet_network_security_group_association" "subnetassoc" {
  subnet_id                 = azurerm_subnet.subnet0.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_public_ip" "pip" {
  name                = "public-ip"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  allocation_method   = "Dynamic"

}

resource "azurerm_network_interface" "nic0" {
  name                = "nic0"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet0.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

}

resource "azurerm_network_interface" "nic1" {
  name                = "nic1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_network_interface" "nic2" {
  name                = "nic2"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }

}


resource "azurerm_windows_virtual_machine" "vm0" {
  name                = "vm0"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  size                = "Standard_DS1_v2"
  admin_username      = "localadm"
  admin_password      = "Passw0rd!2023"
  network_interface_ids = [
    azurerm_network_interface.nic0.id,
  ]

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter"
    version   = "latest"
  }

}

resource "azurerm_windows_virtual_machine" "vm1" {
  name                = "vm1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  size                = "Standard_DS1_v2"
  admin_username      = "localadm"
  admin_password      = "Passw0rd!2023"
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter"
    version   = "latest"
  }

}

resource "azurerm_windows_virtual_machine" "vm2" {
  name                = "vm2"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  size                = "Standard_DS1_v2"
  admin_username      = "localadm"
  admin_password      = "Passw0rd!2023"
  network_interface_ids = [
    azurerm_network_interface.nic2.id,
  ]

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter"
    version   = "latest"
  }

}

resource "azurerm_virtual_network_peering" "peer0tovnet1" {
  name                      = "az104-05-vnet0_to_az104-05-vnet1"
  resource_group_name       = azurerm_resource_group.rg1.name
  virtual_network_name      = azurerm_virtual_network.vnet0.name
  remote_virtual_network_id = azurerm_virtual_network.vnet1.id

}

resource "azurerm_virtual_network_peering" "peer1tovnet0" {
  name                      = "az104-05-vnet1_to_az104-05-vnet0"
  resource_group_name       = azurerm_resource_group.rg1.name
  virtual_network_name      = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet0.id

}

resource "azurerm_virtual_network_peering" "peer0tovnet2" {
  name                      = "az104-05-vnet0_to_az104-05-vnet2"
  resource_group_name       = azurerm_resource_group.rg1.name
  virtual_network_name      = azurerm_virtual_network.vnet0.name
  remote_virtual_network_id = azurerm_virtual_network.vnet2.id

}

resource "azurerm_virtual_network_peering" "peer2tovnet0" {
  name                      = "az104-05-vnet1_to_az104-05-vnet0"
  resource_group_name       = azurerm_resource_group.rg2.name
  virtual_network_name      = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id = azurerm_virtual_network.vnet0.id

}

resource "azurerm_virtual_network_peering" "peer1tovnet2" {
  name                      = "az104-05-vnet1_to_az104-05-vnet2"
  resource_group_name       = azurerm_resource_group.rg1.name
  virtual_network_name      = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet2.id

}

resource "azurerm_virtual_network_peering" "peer2tovnet1" {
  name                      = "az104-05-vnet2_to_az104-05-vnet1"
  resource_group_name       = azurerm_resource_group.rg2.name
  virtual_network_name      = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id = azurerm_virtual_network.vnet1.id

}