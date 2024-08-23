# Create virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "myVnet-snipe-it"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


# Create subnet
resource "azurerm_subnet" "my_terraform_subnet" {
  name                 = "mySubnet-snipe-it"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "myPublicIP-snipe-it"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup-snipe-it"
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
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "myNIC-snipe-it"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "my_nic_configuration-snipe-it"
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

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "my_storage_account" {
  name                     = "stsnipeit"
  location                 = var.resource_group_location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "vm-snipe-it"
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "24_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "snipeit"
  admin_username = var.username

  admin_ssh_key {
    username   = var.username
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCWQYqmcwFST7WkPUW3gne+tFepfz1YPy8dtsq+bVO6yVyl78kHsdhEQyg6et4j5gV4I/C5OMviO1Jaf4N0lJnjpHk7/veQSd/1+4gea/vo8aA3fAzXnsrdCfFY+5txfvKdPzqporuPRJuYQJ2cItZ71h6zB9GmHc7Ct24fcA8FtlB5BjOfslCuhG/TymbCAzeeryYvxXH0O/HAMQXBvEvVo0ZEGct18LMrivtZnydfpaVeyT+OjOFvuKgaFEHuvUi2D4hVrnOt26zgPgr1gnZeoO4RLHt8gV5PmXeUnrxjXI35zpZS+TN/NoupEGm3xVtd7eTO0W6jPMcCKLFk0WDbR2OFdChdDPmn+gnEHkLbji20N5s6+yk/vzgXSn/I+Bs3KIKkvdcz7EYyw5sGBftBXWSJ2yuMZFVa1peee5k8kfXYpo2zkzIBIJ0iXP7i7d0w3eiafcxD1DnCDdBE0FNz9552xHTGSvevuSG9gwh179eILJycrM0+w2B4ivOPVDE= annemarieschmidt@Annemaries-MacBook-Pro.local"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }
}

terraform {
  backend "azurerm" {
    resource_group_name = "rg-snipe-it"
    storage_account_name = "stsnipeit"
    container_name = "c-snipe-it"
    key = "prod.terraform.tfstate"
  }

}
