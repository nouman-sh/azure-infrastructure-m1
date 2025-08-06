resource "random_pet" "lb_hostname" {
}

resource "azurerm_resource_group" "vnet_rg1" {
  name     = "miniproject1"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet_l1" {
  name                = "example-network"
  location            = azurerm_resource_group.vnet_rg1.location
  resource_group_name = azurerm_resource_group.vnet_rg1.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet_l1" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.vnet_rg1.name
  virtual_network_name = azurerm_virtual_network.vnet_l1.name
  address_prefixes     = ["10.0.0.0/20"]
}


resource "azurerm_network_security_group" "nsg_l1" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.vnet_rg1.location
  resource_group_name = azurerm_resource_group.vnet_rg1.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
   security_rule {
    name                       = "test1234"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-ssh"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "myNSG" {
  subnet_id                 = azurerm_subnet.subnet_l1.id
  network_security_group_id = azurerm_network_security_group.nsg_l1.id
}



resource "azurerm_public_ip" "public_l1" {
  name                = "PublicIPForLB"
  location            = azurerm_resource_group.vnet_rg1.location
  resource_group_name = azurerm_resource_group.vnet_rg1.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  domain_name_label   = "${azurerm_resource_group.vnet_rg1.name}-${random_pet.lb_hostname.id}"

}

resource "azurerm_lb" "load_balancer_l1" {
  name                = "myLB"
  location            = azurerm_resource_group.vnet_rg1.location
  resource_group_name = azurerm_resource_group.vnet_rg1.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "myPublicIP"
    public_ip_address_id = azurerm_public_ip.public_l1.id
  }
}

resource "azurerm_lb_backend_address_pool" "bepool" {
  name            = "myBackendAddressPool"
  loadbalancer_id = azurerm_lb.load_balancer_l1.id
 
}

resource "azurerm_lb_rule" "lb_rule_l1" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.load_balancer_l1.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "myPublicIP"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bepool.id]
  probe_id                       = azurerm_lb_probe.lb_prob_l1.id
}

resource "azurerm_lb_probe" "lb_prob_l1" {
  name            = "http-probe"
  loadbalancer_id = azurerm_lb.load_balancer_l1.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}
resource "azurerm_lb_nat_rule" "ssh" {
  name                           = "ssh"
  resource_group_name            = azurerm_resource_group.vnet_rg1.name
  loadbalancer_id                = azurerm_lb.load_balancer_l1.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "myPublicIP"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bepool.id
}

resource "azurerm_public_ip" "natgwpip" {
  name                = "natgw-publicIP"
  location            = azurerm_resource_group.vnet_rg1.location
  resource_group_name = azurerm_resource_group.vnet_rg1.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "nat_gateway_l1" {
  name                    = "nat-Gateway"
  location                = azurerm_resource_group.vnet_rg1.location
  resource_group_name     = azurerm_resource_group.vnet_rg1.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_subnet_nat_gateway_association" "nat_gateway_assoc_l1" {
  subnet_id      = azurerm_subnet.subnet_l1.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway_l1.id
}

# add nat gateway public ip association
resource "azurerm_nat_gateway_public_ip_association" "example" {
  public_ip_address_id = azurerm_public_ip.natgwpip.id
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway_l1.id
}
