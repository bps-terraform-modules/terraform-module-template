# AKS Module

A Terraform module to provision and manage Azure Kubernetes Service (AKS) clusters.

## Usage

```hcl
resource "azurerm_resource_group" "rg-jeff" {
  name     = "rg-jeff"
  location = "southcentralus"
}

module "aks" {
  source = "git@github.com:bps-cloudops/cloudops-modules.git//aks?ref=v1.0.6"

  resource_group             = azurerm_resource_group.rg-jeff
  cluster_name               = "jeff-aks-test"
  kubernetes_version         = "1.30.0"
  log_analytics_workspace_id = module.observability.azurerm_log_analytics_workspace_id

  system_node_pool = {
    vm_size              = "Standard_D2_v2"
    auto_scaling_enabled = true
    node_count           = 1
  }

}
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~>1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~>2.15 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~>2.32 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~>4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 1.15.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.23.0 |
| <a name="provider_azurerm.subscription_bps_devops_sc"></a> [azurerm.subscription\_bps\_devops\_sc](#provider\_azurerm.subscription\_bps\_devops\_sc) | 4.23.0 |
| <a name="provider_azurerm.subscription_shared_services_hub"></a> [azurerm.subscription\_shared\_services\_hub](#provider\_azurerm.subscription\_shared\_services\_hub) | 4.23.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.ssh_public_key](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource_action.ssh_public_key_gen](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource_action) | resource |
| [azurerm_kubernetes_cluster.k8s](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_role_assignment.aks_acr_pull](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.kv_global_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.kv_global_access_secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_subnet.nodes_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.nodes_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.hub_to_nodes](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.nodes_to_hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [random_pet.ssh_key_name](https://registry.terraform.io/providers/hashicorp/random/3.7.1/docs/resources/pet) | resource |
| [azurerm_container_registry.bps_registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_registry) | data source |
| [azurerm_key_vault.bps-devops-kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_virtual_network.hub_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automatic_upgrade_channel"></a> [automatic\_upgrade\_channel](#input\_automatic\_upgrade\_channel) | The channel used for automatic upgrades | `string` | `"none"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | aks cluster's name | `string` | n/a | yes |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of DNS server IP addresses | `list(string)` | <pre>[<br/>  "172.21.216.41",<br/>  "10.4.196.41",<br/>  "172.21.0.4",<br/>  "172.21.0.5",<br/>  "172.21.0.6",<br/>  "172.21.0.7",<br/>  "172.21.0.196"<br/>]</pre> | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | AKS Version Number 1.xx.x | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | n/a | `string` | `null` | no |
| <a name="input_network_profile"></a> [network\_profile](#input\_network\_profile) | Definition for the system node pool | <pre>object({<br/>    network_plugin      = optional(string)<br/>    network_policy      = optional(string)<br/>    network_plugin_mode = optional(string)<br/>    load_balancer_sku   = optional(string)<br/>    pod_cidr            = optional(string) # Overlay pod network<br/>    service_cidr        = optional(string)<br/>    dns_service_ip      = optional(string)<br/>  })</pre> | <pre>{<br/>  "dns_service_ip": "100.64.0.10",<br/>  "load_balancer_sku": "standard",<br/>  "network_plugin": "azure",<br/>  "network_plugin_mode": "overlay",<br/>  "network_policy": "azure",<br/>  "pod_cidr": "100.96.0.0/12",<br/>  "service_cidr": "100.64.0.0/16"<br/>}</pre> | no |
| <a name="input_node_os_upgrade_channel"></a> [node\_os\_upgrade\_channel](#input\_node\_os\_upgrade\_channel) | The channel used for node OS upgrades | `string` | `"NodeImage"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The resource group to create resources in | <pre>object({<br/>    name     = string<br/>    location = string<br/>    id       = string<br/>  })</pre> | n/a | yes |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | List of service endpoints to apply on the azurerm\_subnet | `list(string)` | <pre>[<br/>  "Microsoft.ContainerRegistry",<br/>  "Microsoft.EventHub",<br/>  "Microsoft.KeyVault",<br/>  "Microsoft.Storage",<br/>  "Microsoft.AzureActiveDirectory"<br/>]</pre> | no |
| <a name="input_service_mesh"></a> [service\_mesh](#input\_service\_mesh) | Service mesh to use: 'istio', 'linkerd', or 'none'. | `string` | `"linkerd"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | The SKU tier for the AKS cluster | `string` | `"Free"` | no |
| <a name="input_support_plan"></a> [support\_plan](#input\_support\_plan) | The support plan for the AKS cluster | `string` | `"KubernetesOfficial"` | no |
| <a name="input_system_node_pool"></a> [system\_node\_pool](#input\_system\_node\_pool) | Definition for the system node pool | <pre>object({<br/>    vm_size             = optional(string)<br/>    node_count          = optional(number)<br/>    enable_auto_scaling = optional(bool)<br/>    max_count           = optional(number)<br/>    min_count           = optional(number)<br/>    zones               = optional(list(string))<br/>  })</pre> | <pre>{<br/>  "enable_auto_scaling": false,<br/>  "max_count": null,<br/>  "min_count": null,<br/>  "node_count": 1,<br/>  "vm_size": "Standard_D2_v2",<br/>  "zones": [<br/>    "1",<br/>    "2",<br/>    "3"<br/>  ]<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | BPS Specific Tagging | <pre>object({<br/>    CreatedOn          = string<br/>    CreatedBy          = string<br/>    CreatedFor         = string<br/>    Director           = string<br/>    Environment        = string<br/>    AppName            = string<br/>    CloudOpsAutomation = string<br/>  })</pre> | <pre>{<br/>  "AppName": null,<br/>  "CloudOpsAutomation": "Terraform",<br/>  "CreatedBy": "CloudOpsAutomation",<br/>  "CreatedFor": null,<br/>  "CreatedOn": "",<br/>  "Director": null,<br/>  "Environment": null<br/>}</pre> | no |
| <a name="input_vnet_cidr"></a> [vnet\_cidr](#input\_vnet\_cidr) | IP Range to use for entire AKS cluster | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate) | n/a |
| <a name="output_client_key"></a> [client\_key](#output\_client\_key) | n/a |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | n/a |
| <a name="output_cluster_password"></a> [cluster\_password](#output\_cluster\_password) | n/a |
| <a name="output_cluster_username"></a> [cluster\_username](#output\_cluster\_username) | n/a |
| <a name="output_host"></a> [host](#output\_host) | n/a |
| <a name="output_key_data"></a> [key\_data](#output\_key\_data) | n/a |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | n/a |
| <a name="output_kubernetes_cluster_id"></a> [kubernetes\_cluster\_id](#output\_kubernetes\_cluster\_id) | n/a |
| <a name="output_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#output\_kubernetes\_cluster\_name) | n/a |
| <a name="output_nodes_subnet_id"></a> [nodes\_subnet\_id](#output\_nodes\_subnet\_id) | n/a |
| <a name="output_nodes_vnet_id"></a> [nodes\_vnet\_id](#output\_nodes\_vnet\_id) | n/a |
<!-- END_TF_DOCS -->