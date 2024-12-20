# This file is used for granting access from within the cluster to resources that exist within the bp-devops-sc subscription.
# This is a great central place to store things like container images, secrets, etc


# Attach our main bps registry, https://portal.azure.com/#@cabelas.onmicrosoft.com/resource/subscriptions/1c6cd62a-5175-4ae7-a655-a524541b2cb9/resourceGroups/bp-devops-registry-rg/providers/Microsoft.ContainerRegistry/registries/bpsregistry/overview
# to the aks cluster so we can pull images from it

# reference subscription where the ACR is BP DevOps SC
provider "azurerm" {
  alias           = "subscription_bps_devops_sc"
  subscription_id = "1c6cd62a-5175-4ae7-a655-a524541b2cb9"
  features {}
}

data "azurerm_container_registry" "bps_registry" {
  name                = "bpsregistry"
  resource_group_name = "bp-devops-registry-rg"
  
  provider = azurerm.subscription_bps_devops_sc
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = data.azurerm_container_registry.bps_registry.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
}

# Central key vault used for all things cloudops
data "azurerm_key_vault" "bps-devops-kv" {
  name                = "bps-devops-kv"
  resource_group_name = "bps-devops-secrets"
  
  provider = azurerm.subscription_bps_devops_sc
}

resource "azurerm_role_assignment" "kv_global_access" {
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  role_definition_name = "Key Vault Reader"                     # Role to grant
  scope                = data.azurerm_key_vault.bps-devops-kv.id
}

resource "azurerm_role_assignment" "kv_global_access_secrets" {
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  role_definition_name = "Key Vault Secrets User"                     # Role to grant
  scope                = data.azurerm_key_vault.bps-devops-kv.id
}
