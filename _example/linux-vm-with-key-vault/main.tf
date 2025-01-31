provider "azurerm" {
  features {}
}

module "resource_group" {
  source      = "git::https://github.com/SyncArcs/terraform-azure-resource-group.git?ref=v1.0.0"
  name        = "app"
  environment = "tested"
  location    = "North Europe"
}

module "vnet" {
  source                 = "git::https://github.com/SyncArcs/terraform-azure-vnet.git?ref=v1.0.0"
  name                   = "app"
  environment            = "test"
  resource_group_name    = module.resource_group.resource_group_name
  location               = module.resource_group.resource_group_location
  address_space          = "10.0.0.0/16"
  enable_ddos_pp         = false
  enable_network_watcher = false
}

module "subnet" {
  source               = "git::https://github.com/SyncArcs/terraform-azure-subnet.git?ref=v1.0.0"
  name                 = "app"
  environment          = "test"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.name
  #subnet
  subnet_names    = ["subnet1"]
  subnet_prefixes = ["10.0.1.0/24"]
  # route_table
  enable_route_table = true
  route_table_name   = "default_subnet"
  routes = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}

module "network_security_group" {
  source                  = "git::https://github.com/SyncArcs/terraform-azure-network-security-group.git?ref=v1.0.0"
  name                    = "app"
  environment             = "test"
  resource_group_name     = module.resource_group.resource_group_name
  resource_group_location = module.resource_group.resource_group_location
  subnet_ids              = [module.subnet.default_subnet_id]
  inbound_rules = [
    {
      name                       = "ssh"
      priority                   = 101
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "10.20.0.0/32"
      source_port_range          = "*"
      destination_address_prefix = "0.0.0.0/0"
      destination_port_range     = "22"
      description                = "ssh allowed port"
    },
    {
      name                       = "https"
      priority                   = 102
      access                     = "Allow"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "80,443"
      destination_address_prefix = "0.0.0.0/0"
      destination_port_range     = "22"
      description                = "ssh allowed port"
    }
  ]
}

module "vault" {
  depends_on                  = [module.vnet]
  source                      = "git::https://github.com/SyncArcs/terraform-azure-key-vault.git?ref=v1.0.0"
  name                        = "rohit9876yh"
  environment                 = "test"
  sku_name                    = "standard"
  resource_group_name         = module.resource_group.resource_group_name
  subnet_id                   = module.subnet.default_subnet_id
  virtual_network_id          = module.vnet.id
  enable_private_endpoint     = false
  enable_rbac_authorization   = true
  purge_protection_enabled    = true
  enabled_for_disk_encryption = false
  principal_id                = ["2620a52f-c415-4a08-8656-2335ac73a5d1"]
  role_definition_name        = ["Key Vault Administrator"]

}


module "virtual-machine" {
  source = "../../"
  ## Tags
  name        = "app"
  environment = "test"
  label_order = ["environment", "name"]
  ## Common
  is_vm_linux                     = true
  enabled                         = true
  machine_count                   = 1
  resource_group_name             = module.resource_group.resource_group_name
  location                        = module.resource_group.resource_group_location
  disable_password_authentication = true
  ## Network Interface
  subnet_id                     = [module.subnet.default_subnet_id]
  private_ip_address_version    = "IPv4"
  private_ip_address_allocation = "Static"
  primary                       = true
  private_ip_addresses          = ["10.0.1.6", "10.0.1.7", "10.0.1.8"]
  #nsg
  network_interface_sg_enabled = true
  network_security_group_id    = module.network_security_group.id
  ## Availability Set
  availability_set_enabled     = true
  platform_update_domain_count = 7
  platform_fault_domain_count  = 3
  ## Public IP
  public_ip_enabled = true
  sku               = "Basic"
  allocation_method = "Static"
  ip_version        = "IPv4"
  ## Virtual Machine
  vm_size        = "Standard_B1s"
  public_key     = "ssh-rsa /+/hJiTzqIe7i3eubOeEs9u+/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX+zigP6elp9ygzexHUT/euA/2noUdvEQ40QIq0t0fbvB4MB1I41P3oline1PNA9YlEzj8B3U6KUo6tr9iM6ATpUGvCIYg1kMAAJ1vDzPVIpo9Cpy9kkCuTngv3r6gA6U5vtFxmq2WCa9oKrPuN08bYDZnN5R0XNYERSo8UR78HwyDcUiB+XooXt3zuDkWK4Q90r3L2r14nVSIxmPYQAid/qJv9+1SgjIU649Q1WafeekZvL8MlaH6EYODNB5aYjCtPt1oXkykZGPRgRXYwqaqym4xbqDElv6seKJRpiA2pyE= rohit@rohit"
  admin_username = "ubuntu"
  # admin_password                = "P@ssw0rd!123!" # It is compulsory when disable_password_authentication = false
  caching                         = "ReadWrite"
  disk_size_gb                    = 30
  storage_image_reference_enabled = true
  image_publisher                 = "Canonical"
  image_offer                     = "0001-com-ubuntu-server-focal"
  image_sku                       = "20_04-lts"
  image_version                   = "latest"
  enable_disk_encryption_set      = true
  key_vault_id                    = module.vault.id
  addtional_capabilities_enabled  = true
  ultra_ssd_enabled               = false
  enable_encryption_at_host       = false
  key_vault_rbac_auth_enabled     = true
  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 100
      storage_account_type = "StandardSSD_LRS"
    }
  ]
  # Extension
  extensions = [{
    extension_publisher            = "Microsoft.Azure.Extensions"
    extension_name                 = "hostname"
    extension_type                 = "CustomScript"
    extension_type_handler_version = "2.0"
    auto_upgrade_minor_version     = true
    automatic_upgrade_enabled      = false
    settings                       = <<SETTINGS
    {
      "commandToExecute": "hostname && uptime"
     }
     SETTINGS
  }]
}