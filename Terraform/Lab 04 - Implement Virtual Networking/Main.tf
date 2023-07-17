resource "azurerm_resource_group" "rg" {
  name     = "az104-04-rg1"
  location = "WestEurope"
}

resource "azurerm_private_dns_zone" "dnszone" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = "contoso.org"
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetlink" {
  resource_group_name   = azurerm_resource_group.rg.name
  name                  = "vnetlink"
  private_dns_zone_name = azurerm_private_dns_zone.dnszone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled = "true"


}

resource "azurerm_network_security_group" "nsg" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = "az104-04-nsg01"


}

resource "azurerm_network_security_rule" "nsrule1" {
  name                        = "AllowRDPInBound"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "37.205.44.26/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name

}


resource "azurerm_virtual_network" "vnet" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_network_security_group.nsg.location
  name                = "az104-04-vnet1"
  address_space       = ["10.40.0.0/20"]


}

resource "azurerm_subnet" "subnet0" {
  name                 = "subnet0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.40.0.0/24"]
  

}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.40.1.0/24"]

}

resource "azurerm_subnet_network_security_group_association" "subnetassoc0" {
  subnet_id                 = azurerm_subnet.subnet0.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "subnetassoc1" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_public_ip" "pip0" {
  name                = "az104-04-pip0"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
  tags = {
    ENV = "DEV"
  }
}

resource "azurerm_public_ip" "pip1" {
  name                = "az104-04-pip1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
  tags = {
    ENV = "DEV"
  }
}

resource "azurerm_network_interface" "nic0" {
  name                = "az104-04-nic0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet0.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip0.id
  }

  tags = {
    "ENV" = "DEV"
  }
}

resource "azurerm_network_interface" "nic1" {
  name                = "az104-04-nic1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip1.id
  }

  tags = {
    "ENV" = "DEV"
  }
}

resource "azurerm_windows_virtual_machine" "vm0" {
  name                = "az104-04-vm0"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
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
  name                = "az104-04-vm1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
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





