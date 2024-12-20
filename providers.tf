terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.32"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.15"
    }
  }
}