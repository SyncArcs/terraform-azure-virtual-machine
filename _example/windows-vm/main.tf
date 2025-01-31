provider "azurerm" {
  features {}
}

module "resource_group" {
  source      = "git::https://github.com/SyncArcs/terraform-azure-resource-group.git?ref=v1.0.0"
  name        = "app-window"
  environment = "tested"
  location    = "North Europe"
}

module "vnet" {
  source              = "git::https://github.com/SyncArcs/terraform-azure-vnet.git?ref=v1.0.0"
  name                = "app-window"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
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



module "virtual-machine" {
  source      = "../../"
  name        = "app"
  environment = "test"
  ## Common
  is_vm_windows       = true
  enabled             = true
  machine_count       = 1
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  create_option       = "Empty"
  disk_size_gb        = 128
  provision_vm_agent  = true
  ## Network Interface
  subnet_id                     = [module.subnet.default_subnet_id]
  private_ip_address_version    = "IPv4"
  private_ip_address_allocation = "Dynamic"
  primary                       = true
  # private_ip_addresses          = ["10.0.1.4"]
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
  #os_type       = "windows"
  computer_name = "app-win-comp"
  # windows_distribution_name = "windows2019dc"
  vm_size         = "Standard_B1s"
  admin_username  = "azureadmin"
  admin_password  = "Password@123"
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2019-Datacenter"
  image_version   = "latest"
  caching         = "ReadWrite"

  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 128
      storage_account_type = "StandardSSD_LRS"
    }
    # , {
    #   name                 = "disk2"
    #   disk_size_gb         = 200
    #   storage_account_type = "StandardSSD_LRS"
    # }
  ]

  # Extension
  extensions = [{
    extension_publisher            = "Microsoft.Azure.Security"
    extension_name                 = "CustomExt"
    extension_type                 = "IaaSAntimalware"
    extension_type_handler_version = "1.3"
    auto_upgrade_minor_version     = true
    automatic_upgrade_enabled      = false
    settings                       = <<SETTINGS
                                        {
                                          "AntimalwareEnabled": true,
                                          "RealtimeProtectionEnabled": "true",
                                          "ScheduledScanSettings": {
                                              "isEnabled": "false",
                                              "day": "7",
                                              "time": "120",
                                              "scanType": "Quick"
                                          },
                                          "Exclusions": {
                                              "Extensions": "",
                                              "Paths": "",
                                              "Processes": ""
                                          }
                                        }
                                      SETTINGS
  }]

}
