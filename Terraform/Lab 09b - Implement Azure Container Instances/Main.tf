resource "azurerm_resource_group" "rg" {
  name     = "az104-09b-rg1"
  location = var.resource_group_location
}

resource "azurerm_container_group" "container" {
  name                = "acigroup01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  dns_name_label      = "aci-public-09887766"
  os_type             = "Linux"
  restart_policy      = var.restart_policy

  container {
    name   = "az104-9b-c1"
    image  = var.image
    cpu    = var.cpu_cores
    memory = var.memory_in_gb

    ports {
      port     = var.port
      protocol = "TCP"
    }
  }

}