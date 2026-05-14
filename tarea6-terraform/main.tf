# Tarea 6 - Terraform IaC: Provisioning de Infraestructura Azure
# Alumno: Javier López Ramos (JJLR)
# Fecha: Mayo 2026

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Variables
variable "subscription_id" {
  description = "Azure Subscription ID"
  default     = "33b67b58-295c-435c-8a86-9aaffe6fa0d5"
}

variable "location" {
  description = "Azure region"
  default     = "westeurope"
}

variable "prefix" {
  description = "Resource prefix"
  default     = "tf-jjlr"
}

variable "admin_username" {
  description = "VM admin username"
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDT8M8pcogxypBOJ3ChMECeQEgtGyNGSt6+p+5A3LZjXpfvyG5mKiGPHh6xbzFfeW0QLXHIMLAvMFGMMci/NJuHd9Vp6KMFZf+oQOPefn+fS+n050CeM0Ro+cnO391Q2Y/NhJAdrJRJr5DKFov3GYF29Fk5icpfjvnTTZeo3qDTIurQEpX2I1T0bia0GfLEq6mtOo8ARBV/j+hyj9REvMOoRVUEIWSu5VrURTHPXZGWEpTI+3EkHtmf393zQP2wgLcdcKIaLjdxiUHYFrVR74iODaRElRXJqRkwK5IhDsLRIeGokpZkXz+bRPVov1XtR38Z/wLLewl/hqOzPYfFn0PGedofE+cxy1Pp/L8AdRAGitlh8H6LxJeHL9RzbTnO+aTGc+iZKSDF5Wg0QbOtjblFTuIi6cGs3N64s5q1x2TxDW7rM5GBz03aP4yXu8Lw624PfQqvfXwtzEs7J9vLjmtTAs5SawxrvwGeZ8cyo8IJqsK+GJu4HZHcsTmPOZNalX0="
}

# Use existing Resource Group (Azure Policy restricts creating new ones)
data "azurerm_resource_group" "rg" {
  name = "dev-rg-devops-jesus-lopez-ramos"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags = { Environment = "DevOps-UAX", Alumno = "JJLR" }
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = { Environment = "DevOps-UAX", Alumno = "JJLR" }
}

# Subnet NSG Association
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Public IP
resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = { Alumno = "JJLR" }
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
  tags = { Alumno = "JJLR" }
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.prefix}-vm"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"
  admin_username      = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    name                 = "${var.prefix}-osdisk"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Environment = "DevOps-UAX"
    Alumno      = "JJLR"
    Tarea       = "Tarea6-Terraform"
    ManagedBy   = "Terraform"
  }
}

# Outputs
output "resource_group" {
  value = data.azurerm_resource_group.rg.name
}
output "vm_name" {
  value = azurerm_linux_virtual_machine.vm.name
}
output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}
output "private_ip" {
  value = azurerm_network_interface.nic.private_ip_address
}
