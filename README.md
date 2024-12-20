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

## Inputs

| Name            | Description                                      | Type     | Default  | Required |
|-----------------|--------------------------------------------------|----------|----------|----------|
| `name`          | Name of the AKS cluster                          | `string` | n/a      | yes      |



