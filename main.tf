# the code is tested and valid By Simcha Vizel 

resource "azurerm_resource_group" "Dxc-Demo" {
  name     = "Dxc-Demo"
  location = "westeurope"
}

resource "azurerm_virtual_network" "RRAS-S2S-Vnet" {
  name                = "RRAS-S2S-Vnet"
  location            = "${azurerm_resource_group.Dxc-Demo.location}"
  resource_group_name = "${azurerm_resource_group.Dxc-Demo.name}"
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "default_subnet" {
  name                 = "default_subnet"
  resource_group_name  = "${azurerm_resource_group.Dxc-Demo.name}"
  virtual_network_name = "${azurerm_virtual_network.RRAS-S2S-Vnet.name}"
  address_prefix       = "10.2.0.0/24"
}
resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = "${azurerm_resource_group.Dxc-Demo.name}"
  virtual_network_name = "${azurerm_virtual_network.RRAS-S2S-Vnet.name}"
  address_prefix       = "10.2.1.0/24"
}

resource "azurerm_local_network_gateway" "RRAS-S2S-LclNetGW" {
  name                = "RRAS-S2S-LclNetGW"
  location            = "${azurerm_resource_group.Dxc-Demo.location}"
  resource_group_name = "${azurerm_resource_group.Dxc-Demo.name}"
  gateway_address     = "192.168.1.200"
  address_space       = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "public_ip"
  location            = "${azurerm_resource_group.Dxc-Demo.location}"
  resource_group_name = "${azurerm_resource_group.Dxc-Demo.name}"
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "RRAS-S2S-VnetGW" {
  name                = "RRAS-S2S-VnetGW"
  location            = "${azurerm_resource_group.Dxc-Demo.location}"
  resource_group_name = "${azurerm_resource_group.Dxc-Demo.name}"

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    public_ip_address_id          = "${azurerm_public_ip.public_ip.id}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "${azurerm_subnet.GatewaySubnet.id}"
  }
}

resource "azurerm_virtual_network_gateway_connection" "RRAS-S2S-LclNetGW-Connection" {
  name                = "RRAS-S2S-LclNetGW-Connection"
 location            = "${azurerm_resource_group.Dxc-Demo.location}"
  resource_group_name = "${azurerm_resource_group.Dxc-Demo.name}"

  type                       = "IPsec"
  virtual_network_gateway_id = "${azurerm_virtual_network_gateway.RRAS-S2S-VnetGW.id}"
  local_network_gateway_id   = "${azurerm_local_network_gateway.RRAS-S2S-LclNetGW.id}"

  shared_key = "Use a strong password"
}