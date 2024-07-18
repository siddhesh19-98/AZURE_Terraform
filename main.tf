terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.111.0"
    }
  }
}

provider "azurerm" {
subscription_id = "e7c2f1ae-5e2f-4761-9d5e-b39670e2943c"
tenant_id = "1e8a6e67-3e74-4ce1-ba7f-731318ddc516"
client_id = "fce313a4-1bdd-410d-b7be-9a499a334a66"
client_secret = "2EX8Q~ZxRcNxVJyb~zDkyeKVH-pO22rrDtN4OaD2"

  features {}

}
locals {
    resource_group_name= "newrg1"
    location= "West Europe"
}


resource "azurerm_resource_group" "rg1" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_virtual_network" "network1" {
  name                = "vnet1"
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = ["10.0.0.0/16"]
 

depends_on = [ azurerm_resource_group.rg1 ]

}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = local.resource_group_name
  virtual_network_name = "vnet1"
  address_prefixes     = ["10.0.6.0/24"]

  depends_on = [ azurerm_virtual_network.network1]

}

resource "azurerm_network_interface" "nic1" {
  name                = "netinterface"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.appip.id

  }

depends_on = [ azurerm_subnet.subnet1 ]
}
resource "azurerm_public_ip" "appip" {
  name                = "appip1"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"

depends_on =[azurerm_resource_group.rg1]
}

resource "azurerm_network_security_group" "nsg-1" {
  name                = "nsg-1"
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
depends_on = [ azurerm_resource_group.rg1 ]
}
resource "azurerm_subnet_network_security_group_association" "nsglink" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg-1.id
}
