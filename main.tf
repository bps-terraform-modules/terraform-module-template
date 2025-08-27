resource "azurerm_virtual_network" "nodes_vnet" {
  name                = "vnet-nodes-${var.cluster_name}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  address_space       = [var.vnet_cidr]
  dns_servers         = var.dns_servers

  tags = var.tags

}

resource "azurerm_subnet" "nodes_subnet" {
  name                              = "subnet-nodes-${var.cluster_name}"
  resource_group_name               = var.resource_group.name
  virtual_network_name              = azurerm_virtual_network.nodes_vnet.name
  address_prefixes                  = [var.vnet_cidr]
  service_endpoints                 = var.service_endpoints
  private_endpoint_network_policies = "Enabled"

}

resource "azurerm_kubernetes_cluster" "k8s" {
  location                            = var.resource_group.location
  name                                = var.cluster_name
  resource_group_name                 = var.resource_group.name
  kubernetes_version                  = var.kubernetes_version
  oidc_issuer_enabled                 = true
  workload_identity_enabled           = true
  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = true #this creates azure public dns record that only resolves to internal
  private_dns_zone_id                 = "None"
  dns_prefix                          = var.cluster_name
  azure_policy_enabled                = true
  tags                                = var.tags

  automatic_upgrade_channel = var.automatic_upgrade_channel
  node_os_upgrade_channel   = var.node_os_upgrade_channel
  sku_tier                  = var.sku_tier
  support_plan              = var.support_plan
  monitor_metrics {
    annotations_allowed = null
    labels_allowed      = null
  }
  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_pool.vm_size
    auto_scaling_enabled         = var.system_node_pool.enable_auto_scaling
    node_count                   = var.system_node_pool.node_count
    max_count                    = var.system_node_pool.max_count
    min_count                    = var.system_node_pool.min_count
    vnet_subnet_id               = azurerm_subnet.nodes_subnet.id
    only_critical_addons_enabled = true
    os_sku                       = "Ubuntu"
    temporary_name_for_rotation  = "systemtemp"
    zones                        = var.system_node_pool.zones

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }
  linux_profile {
    admin_username = "azureadmin"

    ssh_key {
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }
  network_profile {
    network_plugin      = var.network_profile.network_plugin
    network_policy      = var.network_profile.network_policy
    network_plugin_mode = var.network_profile.network_plugin_mode
    load_balancer_sku   = var.network_profile.load_balancer_sku
    pod_cidr            = var.network_profile.pod_cidr
    service_cidr        = var.network_profile.service_cidr
    dns_service_ip      = var.network_profile.dns_service_ip
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = ["7bd0d290-f340-4da1-8896-7e16d749605f"] ## t1_pd_acl_azure_cloudadmin
  }
  storage_profile {
    blob_driver_enabled = true
    disk_driver_enabled = true
    file_driver_enabled = true
  }

  dynamic "service_mesh_profile" {
    for_each = var.service_mesh == "istio" ? [1] : []

    content {
      mode                             = "Istio"
      internal_ingress_gateway_enabled = true
      revisions                        = ["asm-1-21"]
    }
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []

    content {
      log_analytics_workspace_id      = var.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = true
    }
  }

  dynamic "microsoft_defender" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []

    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id

    }
  }

  depends_on = [azurerm_virtual_network_peering.nodes_to_hub]
}

# This enables the cluster to deploy an internal load balancer if nginx is provided
resource "azurerm_role_assignment" "network_contributor" {
  scope                = azurerm_virtual_network.nodes_vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.identity[0].principal_id

}

data "azurerm_virtual_network" "hub_vnet" {
  name                = "AZRSCSHSPVnet01-172.21.0.0-23"
  resource_group_name = "AZRSCSHSPVnet01-RG"
  provider            = azurerm.subscription_shared_services_hub

}

provider "azurerm" {
  alias           = "subscription_shared_services_hub"
  subscription_id = "2b3da8b3-9381-432b-9423-7006df1091d7"
  features {}
}

# Peering from internal_vnet that sits next to AKS to our hub network which is connected to on premise
# AKS -> Hub
resource "azurerm_virtual_network_peering" "nodes_to_hub" {
  name                      = "vnet-nodes-${var.cluster_name}-to-hub"
  resource_group_name       = var.resource_group.name
  virtual_network_name      = azurerm_virtual_network.nodes_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub_vnet.id

  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  allow_virtual_network_access = true
  use_remote_gateways          = true

}

# Peering from our hub network that is connected to onpremise to the internal_vnet that sits next to AKS
# Hub -> AKS
resource "azurerm_virtual_network_peering" "hub_to_nodes" {
  name                      = "hub-to-vnet-nodes-${var.cluster_name}"
  resource_group_name       = "AZRSCSHSPVnet01-RG"
  virtual_network_name      = "AZRSCSHSPVnet01-172.21.0.0-23"
  remote_virtual_network_id = azurerm_virtual_network.nodes_vnet.id
  provider                  = azurerm.subscription_shared_services_hub

  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  allow_virtual_network_access = true
  use_remote_gateways          = false
}


