
variable "resource_group" {
  description = "The resource group to create resources in"
  type = object({
    name     = string
    location = string
    id       = string
  })
}

variable "tags" {
  description = "BPS Specific Tagging"
  type = object({
    CreatedOn          = string
    CreatedBy          = string
    CreatedFor         = string
    Director           = string
    Environment        = string
    AppName            = string
    CloudOpsAutomation = string
  })

  default = {
    CreatedOn          = ""
    CreatedBy          = "CloudOpsAutomation"
    CreatedFor         = null
    Director           = null
    Environment        = null
    AppName            = null
    CloudOpsAutomation = "Terraform"
  }

  validation {
    condition     = contains(["dev", "staging", "non-prod", "prod", "production", "sandbox", "test"], var.tags.Environment)
    error_message = "Invalid Environment. Allowed values are: 'dev', 'staging', 'non-prod', 'prod', 'production', 'sandbox', 'test'."
  }

  validation {
    condition     = can(regex("^\\d{4}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])$", var.tags.CreatedOn))
    error_message = "Invalid CreatedOn format. It must be in 'yyyymmdd' format (e.g., 20230918)."
  }
}

variable "cluster_name" {
  type        = string
  default     = "jeff-aks-test"
  description = "aks cluster's name"
}

variable "kubernetes_version" {
  type        = string
  description = "AKS Version Number 1.xx.x"
  default     = "1.30.0"
}

variable "service_mesh" {
  description = "Service mesh to use: 'istio', 'linkerd', or 'none'."
  type        = string
  validation {
    condition     = contains(["istio", "linkerd", "none"], var.service_mesh)
    error_message = "Invalid service mesh. Allowed values are: 'istio', 'linkerd', 'none'."
  }
}

variable "ingress" {
  description = "Ingress Type to use: 'nginx' or 'none'."
  type        = string
  validation {
    condition     = contains(["nginx", "none"], var.ingress)
    error_message = "Invalid values for ingress. Allowed values are: 'nginx', 'none'."
  }
}

variable "system_node_pool" {
  description = "Definition for the system node pool"
  type = object({
    vm_size             = optional(string)
    node_count          = optional(number)
    enable_auto_scaling = optional(bool)
    max_count           = optional(number)
    min_count           = optional(number)
    vnet_cidr           = string
  })

  default = {
    vm_size             = "Standard_D2_v2"
    enable_auto_scaling = false
    node_count          = 1
    max_count           = null
    min_count           = null
    vnet_cidr           = ""

  }
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "dns_servers" {
  description = "List of DNS server IP addresses"
  type        = list(string)
  default     = ["172.21.216.41", "10.4.196.41", "172.21.0.4", "172.21.0.5", "172.21.0.6", "172.21.0.7", "172.21.0.196"]
}

variable "service_endpoints" {
  description = "List of service endpoints to apply on the azurerm_subnet"
  type        = list(string)
  default     = ["Microsoft.ContainerRegistry", "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.AzureActiveDirectory"]

}
