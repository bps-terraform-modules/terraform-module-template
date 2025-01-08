provider "azurerm" {
  alias           = "subscription_bps_devops_sc"
  subscription_id = "1c6cd62a-5175-4ae7-a655-a524541b2cb9"
  features {}
}

# Central key vault used for all things cloudops
data "azurerm_key_vault" "bps-devops-kv" {
  name                = "bps-devops-kv"
  resource_group_name = "bps-devops-secrets"

  provider = azurerm.subscription_bps_devops_sc
}

# PAT from github, that is stored in our azure keyvault. The user that generates this PAT needs to have access to appropriate repo/org
# https://github.com/settings/tokens
data "azurerm_key_vault_secret" "repo-pat" {
  name         = var.key_vault_name
  key_vault_id = data.azurerm_key_vault.bps-devops-kv.id
}

resource "helm_release" "helm-arc" {
  name             = "actions-runner-controller"
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart            = "gha-runner-scale-set-controller"
  create_namespace = true
  namespace        = "github"

  set {
    name  = "githubConfigSecret.github_token"
    value = data.azurerm_key_vault_secret.repo-pat.value

  }

}

resource "helm_release" "helm-arc-runners" {
  name       = var.runner_name
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set"
  namespace  = "github"

  set {
    name  = "githubConfigUrl"
    value = var.github_url

  }

  set {
    name  = "githubConfigSecret.github_token"
    value = data.azurerm_key_vault_secret.repo-pat.value

  }

  set {
    name  = "controllerServiceAccount.namespace"
    value = "github"

  }

  set {
    name  = "controllerServiceAccount.name"
    value = "actions-runner-controller-gha-rs-controller"

  }

}
