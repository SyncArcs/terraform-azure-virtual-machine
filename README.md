# Terraform-azure-virtual-machine

# Terraform Azure Cloud Virtual-Machine Module

## Table of Contents
- [Introduction](#introduction)
- [Usage](#usage)
- [Examples](#examples)
- [Author](#author)
- [License](#license)
- [Inputs](#inputs)
- [Outputs](#outputs)

## Introduction
This module provides a Terraform configuration for deploying various Azure resources as part of your infrastructure. The configuration includes the deployment of resource groups, virtual networks, subnets, network security groups, Azure Key Vault, and virtual machines.

## Usage
To use this module, you should have Terraform installed and configured for AZURE. This module provides the necessary Terraform configuration
for creating AZURE resources, and you can customize the inputs as needed. Below is an example of how to use this module:

# Examples

# Example: linux-vm

```hcl
module "virtual-machine" {
  source                          = "cypik/virtual-machine/azure"
  version                         = "1.0.2"
  ## Tags
  name                            = "apouq"
  environment                     = "test"
  label_order                     = ["environment", "name"]
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
  private_ip_addresses          = ["10.0.1.6"]
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
  public_key     = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  admin_username = "ubuntu"
  # admin_password                = "P@ssw0rd!123!" # It is compulsory when disable_password_authentication = false
  caching                         = "ReadWrite"
  disk_size_gb                    = 30
  storage_image_reference_enabled = true
  image_publisher                 = "Canonical"
  image_offer                     = "0001-com-ubuntu-server-focal"
  image_sku                       = "20_04-lts"
  image_version                   = "latest"
  key_vault_id                    = module.vault.id
  addtional_capabilities_enabled  = true
  ultra_ssd_enabled               = false
  enable_encryption_at_host       = false
  key_vault_rbac_auth_enabled     = false
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
```

# Example: linux-vm-with-key-vault

```hcl
module "virtual-machine" {
  source                          = "cypik/virtual-machine/azure"
  version                         = "1.0.2"
  ## Tags
  name                            = "apouq"
  environment                     = "test"
  label_order                     = ["environment", "name"]
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
  private_ip_addresses          = ["10.0.1.6"]
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
  public_key     = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
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
  key_vault_rbac_auth_enabled     = false
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
```

# Example: Windows-vm

```hcl
module "virtual-machine" {
  source                        = "cypik/virtual-machine/azure"
  version                       = "1.0.2"
  ## Tags
  name                          = "app"
  environment                   = "test"
  ## Common
  is_vm_windows                 = true
  enabled                       = true
  machine_count                 = 1
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  create_option                 = "Empty"
  disk_size_gb                  = 128
  provision_vm_agent            = true
  ## Network Interface
  subnet_id                     = [module.subnet.default_subnet_id]
  private_ip_address_version    = "IPv4"
  private_ip_address_allocation = "Dynamic"
  primary                       = true
  network_interface_sg_enabled  = true
  network_security_group_id     = module.network_security_group.id
  ## Availability Set
  availability_set_enabled      = true
  platform_update_domain_count  = 7
  platform_fault_domain_count   = 3
  ## Public IP
  public_ip_enabled             = true
  sku                           = "Basic"
  allocation_method             = "Static"
  ip_version                    = "IPv4"
  os_type                       = "windows"
  computer_name                 = "app-win-comp"
  vm_size                       = "Standard_B1s"
  admin_username                = "azureadmin"
  admin_password                = "Password@123"
  image_publisher               = "MicrosoftWindowsServer"
  image_offer                   = "WindowsServer"
  image_sku                     = "2019-Datacenter"
  image_version                 = "latest"
  caching                       = "ReadWrite"

  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 128
      storage_account_type = "StandardSSD_LRS"
    }
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
```
This example demonstrates how to create various AZURE resources using the provided modules. Adjust the input values to suit your specific requirements.

## Examples
For detailed examples on how to use this module, please refer to the [examples](https://github.com/cypik/terraform-azure-virtual-machine/blob/master/_example) directory within this repository.

## License
This Terraform module is provided under the **MIT** License. Please see the [LICENSE](https://github.com/cypik/terraform-azure-virtual-machine/blob/master/LICENSE) file for more details.

## Author
Your Name
Replace **MIT** and **Cypik** with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_labels"></a> [labels](#module\_labels) | cypik/labels/azure | 1.0.2 |

## Resources

| Name | Type |
|------|------|
| [azurerm_availability_set.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set) | resource |
| [azurerm_disk_encryption_set.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/disk_encryption_set) | resource |
| [azurerm_key_vault_access_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_key.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_linux_virtual_machine.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_managed_disk.data_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_public_ip.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_role_assignment.azurerm_disk_encryption_set_key_vault_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.key_vault_crypto_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_virtual_machine_data_disk_attachment.data_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.vm_insight_monitor_agent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_windows_virtual_machine.win_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerated_networking_enabled"></a> [accelerated\_networking\_enabled](#input\_accelerated\_networking\_enabled) | Should Accelerated Networking be enabled? Defaults to false. | `bool` | `false` | no |
| <a name="input_addtional_capabilities_enabled"></a> [addtional\_capabilities\_enabled](#input\_addtional\_capabilities\_enabled) | Whether additional capabilities block is enabled. | `bool` | `false` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | The password associated with the local administrator account.NOTE:- Optional for Linux Vm but REQUIRED for Windows VM | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Specifies the name of the local administrator account.NOTE:- Optional for Linux Vm but REQUIRED for Windows VM | `string` | `""` | no |
| <a name="input_allocation_method"></a> [allocation\_method](#input\_allocation\_method) | Defines the allocation method for this IP address. Possible values are Static or Dynamic. | `string` | `""` | no |
| <a name="input_allow_extension_operations"></a> [allow\_extension\_operations](#input\_allow\_extension\_operations) | (Optional) Should Extension Operations be allowed on this Virtual Machine? Defaults to true. | `bool` | `true` | no |
| <a name="input_availability_set_enabled"></a> [availability\_set\_enabled](#input\_availability\_set\_enabled) | Whether availability set is enabled. | `bool` | `false` | no |
| <a name="input_blob_endpoint"></a> [blob\_endpoint](#input\_blob\_endpoint) | The Storage Account's Blob Endpoint which should hold the virtual machine's diagnostic files | `string` | `""` | no |
| <a name="input_boot_diagnostics_enabled"></a> [boot\_diagnostics\_enabled](#input\_boot\_diagnostics\_enabled) | Whether boot diagnostics block is enabled. | `bool` | `false` | no |
| <a name="input_caching"></a> [caching](#input\_caching) | Specifies the caching requirements for the OS Disk. Possible values include None, ReadOnly and ReadWrite. | `string` | `""` | no |
| <a name="input_computer_name"></a> [computer\_name](#input\_computer\_name) | Name of the Windows Computer Name. | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Used when creating the Resource Group. | `string` | `"60m"` | no |
| <a name="input_create_option"></a> [create\_option](#input\_create\_option) | Specifies how the azure managed Disk should be created. Possible values are Attach (managed disks only) and FromImage. | `string` | `"Empty"` | no |
| <a name="input_custom_image_id"></a> [custom\_image\_id](#input\_custom\_image\_id) | Specifies the ID of the Custom Image which the Virtual Machine should be created from. | `string` | `""` | no |
| <a name="input_data_disks"></a> [data\_disks](#input\_data\_disks) | Managed Data Disks for azure virtual machine | <pre>list(object({<br>    name                 = string<br>    storage_account_type = string<br>    disk_size_gb         = number<br>  }))</pre> | `[]` | no |
| <a name="input_ddos_protection_mode"></a> [ddos\_protection\_mode](#input\_ddos\_protection\_mode) | The DDoS protection mode of the public IP | `string` | `"VirtualNetworkInherited"` | no |
| <a name="input_dedicated_host_id"></a> [dedicated\_host\_id](#input\_dedicated\_host\_id) | (Optional) The ID of a Dedicated Host where this machine should be run on. Conflicts with dedicated\_host\_group\_id. | `string` | `null` | no |
| <a name="input_delete"></a> [delete](#input\_delete) | Used when deleting the Resource Group. | `string` | `"60m"` | no |
| <a name="input_disable_password_authentication"></a> [disable\_password\_authentication](#input\_disable\_password\_authentication) | Specifies whether password authentication should be disabled. | `bool` | `false` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | Specifies the size of the OS Disk in gigabytes. | `number` | `8` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of IP addresses of DNS servers. | `list(string)` | `[]` | no |
| <a name="input_domain_name_label"></a> [domain\_name\_label](#input\_domain\_name\_label) | Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system. | `string` | `null` | no |
| <a name="input_enable_automatic_updates"></a> [enable\_automatic\_updates](#input\_enable\_automatic\_updates) | (Optional) Specifies if Automatic Updates are Enabled for the Windows Virtual Machine. Changing this forces a new resource to be created. Defaults to true. | `bool` | `true` | no |
| <a name="input_enable_disk_encryption_set"></a> [enable\_disk\_encryption\_set](#input\_enable\_disk\_encryption\_set) | n/a | `bool` | `false` | no |
| <a name="input_enable_encryption_at_host"></a> [enable\_encryption\_at\_host](#input\_enable\_encryption\_at\_host) | Flag to control Disk Encryption at host level | `bool` | `false` | no |
| <a name="input_enable_os_disk_write_accelerator"></a> [enable\_os\_disk\_write\_accelerator](#input\_enable\_os\_disk\_write\_accelerator) | Should Write Accelerator be Enabled for this OS Disk? This requires that the `storage_account_type` is set to `Premium_LRS` and that `caching` is set to `None`. | `any` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Flag to control the module creation. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_extensions"></a> [extensions](#input\_extensions) | List of extensions for azure virtual machine | `any` | `[]` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Additional tags (e.g. map(`BusinessUnit`,`XYZ`). | `map(string)` | `{}` | no |
| <a name="input_identity_enabled"></a> [identity\_enabled](#input\_identity\_enabled) | Whether identity block is enabled. | `bool` | `false` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of user managed identity ids to be assigned to the VM. | `list(any)` | `[]` | no |
| <a name="input_idle_timeout_in_minutes"></a> [idle\_timeout\_in\_minutes](#input\_idle\_timeout\_in\_minutes) | Specifies the timeout for the TCP idle connection. The value can be set between 4 and 60 minutes. | `number` | `10` | no |
| <a name="input_image_offer"></a> [image\_offer](#input\_image\_offer) | Specifies the offer of the image used to create the virtual machine. | `string` | `""` | no |
| <a name="input_image_publisher"></a> [image\_publisher](#input\_image\_publisher) | Specifies the publisher of the image used to create the virtual machine. | `string` | `""` | no |
| <a name="input_image_sku"></a> [image\_sku](#input\_image\_sku) | Specifies the SKU of the image used to create the virtual machine. | `string` | `""` | no |
| <a name="input_image_version"></a> [image\_version](#input\_image\_version) | Specifies the version of the image used to create the virtual machine. | `string` | `""` | no |
| <a name="input_internal_dns_name_label"></a> [internal\_dns\_name\_label](#input\_internal\_dns\_name\_label) | The (relative) DNS Name used for internal communications between Virtual Machines in the same Virtual Network. | `string` | `null` | no |
| <a name="input_ip_forwarding_enabled"></a> [ip\_forwarding\_enabled](#input\_ip\_forwarding\_enabled) | Should IP Forwarding be enabled? Defaults to false. | `bool` | `false` | no |
| <a name="input_ip_version"></a> [ip\_version](#input\_ip\_version) | The IP Version to use, IPv6 or IPv4. | `string` | `""` | no |
| <a name="input_is_vm_linux"></a> [is\_vm\_linux](#input\_is\_vm\_linux) | Create Linux Virtual Machine. | `bool` | `false` | no |
| <a name="input_is_vm_windows"></a> [is\_vm\_windows](#input\_is\_vm\_windows) | Create Windows Virtual Machine. | `bool` | `false` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | n/a | `any` | `null` | no |
| <a name="input_key_vault_rbac_auth_enabled"></a> [key\_vault\_rbac\_auth\_enabled](#input\_key\_vault\_rbac\_auth\_enabled) | Flag to state whether rbac authorization is used in key vault or access policy. | `bool` | `true` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | Specifies the BYOL Type for this Virtual Machine. This is only applicable to Windows Virtual Machines. Possible values are Windows\_Client and Windows\_Server. | `string` | `"Windows_Client"` | no |
| <a name="input_linux_patch_mode"></a> [linux\_patch\_mode](#input\_linux\_patch\_mode) | (Optional) Specifies the mode of in-guest patching to this Linux Virtual Machine. Possible values are AutomaticByPlatform and ImageDefault. Defaults to ImageDefault | `string` | `"ImageDefault"` | no |
| <a name="input_location"></a> [location](#input\_location) | Location where resource should be created. | `string` | `""` | no |
| <a name="input_machine_count"></a> [machine\_count](#input\_machine\_count) | Number of Virtual Machines to create. | `number` | `0` | no |
| <a name="input_managed"></a> [managed](#input\_managed) | Specifies whether the availability set is managed or not. Possible values are true (to specify aligned) or false (to specify classic). Default is true. | `bool` | `true` | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'info@cypik.com' | `string` | `"info@cypik.com"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_network_interface_sg_enabled"></a> [network\_interface\_sg\_enabled](#input\_network\_interface\_sg\_enabled) | Whether network interface security group is enabled. | `bool` | `false` | no |
| <a name="input_network_security_group_id"></a> [network\_security\_group\_id](#input\_network\_security\_group\_id) | The ID of the Network Security Group which should be attached to the Network Interface. | `string` | `""` | no |
| <a name="input_os_disk_storage_account_type"></a> [os\_disk\_storage\_account\_type](#input\_os\_disk\_storage\_account\_type) | The Type of Storage Account which should back this the Internal OS Disk. Possible values include Standard\_LRS, StandardSSD\_LRS and Premium\_LRS. | `any` | `"StandardSSD_LRS"` | no |
| <a name="input_patch_assessment_mode"></a> [patch\_assessment\_mode](#input\_patch\_assessment\_mode) | (Optional) Specifies the mode of VM Guest Patching for the Virtual Machine. Possible values are AutomaticByPlatform or ImageDefault. Defaults to ImageDefault. | `string` | `"ImageDefault"` | no |
| <a name="input_plan_enabled"></a> [plan\_enabled](#input\_plan\_enabled) | Whether plan block is enabled. | `bool` | `false` | no |
| <a name="input_plan_name"></a> [plan\_name](#input\_plan\_name) | Specifies the name of the image from the marketplace. | `string` | `""` | no |
| <a name="input_plan_product"></a> [plan\_product](#input\_plan\_product) | Specifies the product of the image from the marketplace. | `string` | `""` | no |
| <a name="input_plan_publisher"></a> [plan\_publisher](#input\_plan\_publisher) | Specifies the publisher of the image. | `string` | `""` | no |
| <a name="input_platform_fault_domain_count"></a> [platform\_fault\_domain\_count](#input\_platform\_fault\_domain\_count) | Specifies the number of fault domains that are used. Defaults to 3. | `number` | `3` | no |
| <a name="input_platform_update_domain_count"></a> [platform\_update\_domain\_count](#input\_platform\_update\_domain\_count) | Specifies the number of update domains that are used. Defaults to 5. | `number` | `5` | no |
| <a name="input_primary"></a> [primary](#input\_primary) | Is this the Primary IP Configuration? Must be true for the first ip\_configuration when multiple are specified. Defaults to false. | `bool` | `false` | no |
| <a name="input_private_ip_address_allocation"></a> [private\_ip\_address\_allocation](#input\_private\_ip\_address\_allocation) | The allocation method used for the Private IP Address. Possible values are Dynamic and Static. | `string` | `"Static"` | no |
| <a name="input_private_ip_address_version"></a> [private\_ip\_address\_version](#input\_private\_ip\_address\_version) | The IP Version to use. Possible values are IPv4 or IPv6. Defaults to IPv4. | `string` | `"IPv4"` | no |
| <a name="input_private_ip_addresses"></a> [private\_ip\_addresses](#input\_private\_ip\_addresses) | The Static IP Address which should be used. | `list(any)` | `[]` | no |
| <a name="input_provision_vm_agent"></a> [provision\_vm\_agent](#input\_provision\_vm\_agent) | Should the Azure Virtual Machine Guest Agent be installed on this Virtual Machine? Defaults to false. | `bool` | `true` | no |
| <a name="input_proximity_placement_group_id"></a> [proximity\_placement\_group\_id](#input\_proximity\_placement\_group\_id) | The ID of the Proximity Placement Group to which this Virtual Machine should be assigned. | `string` | `null` | no |
| <a name="input_public_ip_enabled"></a> [public\_ip\_enabled](#input\_public\_ip\_enabled) | Whether public IP is enabled. | `bool` | `false` | no |
| <a name="input_public_ip_prefix_id"></a> [public\_ip\_prefix\_id](#input\_public\_ip\_prefix\_id) | If specified then public IP address allocated will be provided from the public IP prefix resource. | `string` | `null` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | Name  (e.g. `ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQ`). | `string` | `null` | no |
| <a name="input_read"></a> [read](#input\_read) | Used when retrieving the Resource Group. | `string` | `"5m"` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Terraform current module repo | `string` | `"https://github.com/cypik/terraform-azure-virtual-machine"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the virtual network. | `string` | `""` | no |
| <a name="input_reverse_fqdn"></a> [reverse\_fqdn](#input\_reverse\_fqdn) | A fully qualified domain name that resolves to this public IP address. If the reverseFqdn is specified, then a PTR DNS record is created pointing from the IP address in the in-addr.arpa domain to the reverse FQDN. | `string` | `""` | no |
| <a name="input_sa_type"></a> [sa\_type](#input\_sa\_type) | Specifies the identity type of the Storage Account. At this time the only allowed value is SystemAssigned. | `string` | `"SystemAssigned"` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic. | `string` | `"Basic"` | no |
| <a name="input_source_image_id"></a> [source\_image\_id](#input\_source\_image\_id) | The ID of an Image which each Virtual Machine should be based on | `any` | `null` | no |
| <a name="input_storage_image_reference_enabled"></a> [storage\_image\_reference\_enabled](#input\_storage\_image\_reference\_enabled) | Whether storage image reference is enabled. | `bool` | `false` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the Subnet where this Network Interface should be located in. | `list(any)` | `[]` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Specifies the time zone of the virtual machine. | `string` | `""` | no |
| <a name="input_ultra_ssd_enabled"></a> [ultra\_ssd\_enabled](#input\_ultra\_ssd\_enabled) | Should Ultra SSD disk be enabled for this Virtual Machine?. | `bool` | `false` | no |
| <a name="input_update"></a> [update](#input\_update) | Used when updating the Resource Group. | `string` | `"60m"` | no |
| <a name="input_vm_addon_name"></a> [vm\_addon\_name](#input\_vm\_addon\_name) | The name of the addon Virtual machine's name. | `string` | `null` | no |
| <a name="input_vm_availability_zone"></a> [vm\_availability\_zone](#input\_vm\_availability\_zone) | (Optional) Specifies the Availability Zone in which this Virtual Machine should be located. Changing this forces a new Virtual Machine to be created. | `any` | `null` | no |
| <a name="input_vm_identity_type"></a> [vm\_identity\_type](#input\_vm\_identity\_type) | The Managed Service Identity Type of this Virtual Machine. Possible values are SystemAssigned and UserAssigned. | `string` | `""` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Specifies the size of the Virtual Machine. | `string` | `""` | no |
| <a name="input_windows_patch_mode"></a> [windows\_patch\_mode](#input\_windows\_patch\_mode) | Optional) Specifies the mode of in-guest patching to this Windows Virtual Machine. Possible values are Manual, AutomaticByOS and AutomaticByPlatform. Defaults to AutomaticByOS. | `string` | `"AutomaticByOS"` | no |
| <a name="input_write_accelerator_enabled"></a> [write\_accelerator\_enabled](#input\_write\_accelerator\_enabled) | Specifies if Write Accelerator is enabled on the disk. This can only be enabled on Premium\_LRS managed disks with no caching and M-Series VMs. Defaults to false. | `bool` | `false` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | A collection containing the availability zone to allocate the Public IP in. | `list(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_set_id"></a> [availability\_set\_id](#output\_availability\_set\_id) | The ID of the Availability Set. |
| <a name="output_disk_encryption_set-id"></a> [disk\_encryption\_set-id](#output\_disk\_encryption\_set-id) | n/a |
| <a name="output_extension_id"></a> [extension\_id](#output\_extension\_id) | The ID of the Virtual Machine Extension. |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | Id of key that is to be used for encrypting |
| <a name="output_linux_virtual_machine_id"></a> [linux\_virtual\_machine\_id](#output\_linux\_virtual\_machine\_id) | The ID of the Linux Virtual Machine. |
| <a name="output_network_interface_id"></a> [network\_interface\_id](#output\_network\_interface\_id) | The ID of the Network Interface. |
| <a name="output_network_interface_private_ip_addresses"></a> [network\_interface\_private\_ip\_addresses](#output\_network\_interface\_private\_ip\_addresses) | The private IP addresses of the network interface. |
| <a name="output_network_interface_sg_association_id"></a> [network\_interface\_sg\_association\_id](#output\_network\_interface\_sg\_association\_id) | The (Terraform specific) ID of the Association between the Network Interface and the Network Interface. |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | The IP address value that was allocated. |
| <a name="output_public_ip_id"></a> [public\_ip\_id](#output\_public\_ip\_id) | The Public IP ID. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags associated to resources. |
| <a name="output_windows_virtual_machine_id"></a> [windows\_virtual\_machine\_id](#output\_windows\_virtual\_machine\_id) | The ID of the Windows Virtual Machine. |
<!-- END_TF_DOCS -->