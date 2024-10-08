# Create virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "Vnet-snipe-it"
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

# Create subnet
resource "azurerm_subnet" "my_terraform_subnet" {
  name                 = "Subnet-snipe-it"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "PublicIP-snipe-it"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "NetworkSecurityGroup-snipe-it"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 1021
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "NIC-snipe-it"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "nic_configuration-snipe-it"
    subnet_id                     = azurerm_subnet.my_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.my_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "vm-snipe-it"
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "snipeitDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "snipeit"
  admin_username = var.username

  admin_ssh_key {
    username   = var.username
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCWQYqmcwFST7WkPUW3gne+tFepfz1YPy8dtsq+bVO6yVyl78kHsdhEQyg6et4j5gV4I/C5OMviO1Jaf4N0lJnjpHk7/veQSd/1+4gea/vo8aA3fAzXnsrdCfFY+5txfvKdPzqporuPRJuYQJ2cItZ71h6zB9GmHc7Ct24fcA8FtlB5BjOfslCuhG/TymbCAzeeryYvxXH0O/HAMQXBvEvVo0ZEGct18LMrivtZnydfpaVeyT+OjOFvuKgaFEHuvUi2D4hVrnOt26zgPgr1gnZeoO4RLHt8gV5PmXeUnrxjXI35zpZS+TN/NoupEGm3xVtd7eTO0W6jPMcCKLFk0WDbR2OFdChdDPmn+gnEHkLbji20N5s6+yk/vzgXSn/I+Bs3KIKkvdcz7EYyw5sGBftBXWSJ2yuMZFVa1peee5k8kfXYpo2zkzIBIJ0iXP7i7d0w3eiafcxD1DnCDdBE0FNz9552xHTGSvevuSG9gwh179eILJycrM0+w2B4ivOPVDE= annemarieschmidt@Annemaries-MacBook-Pro.local"
  }
}


terraform {
  backend "azurerm" {
    resource_group_name = "rg-snipeit-prod-gwc-001"
    storage_account_name = "statesnipeit"
    container_name = "c-terraform-state"
    key = "prod.terraform.tfstate"
  }

}
