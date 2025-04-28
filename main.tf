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
  for_each = { for release in var.github_urls : release.name => release }
  name       = "${var.runner_name}-${each.value.name}"
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set"
  namespace  = "github"

  values = [file("${path.module}/runner-values.yaml")]

  set {
    name  = "githubConfigUrl"
    value = each.value.url

  }

  set {
    name  = "githubConfigSecret.github_token"
    value = data.azurerm_key_vault_secret.repo-pat.value

  }

  set {
    name  = "template.controllerServiceAccount.namespace"
    value = "github"

  }

  set {
    name  = "template.controllerServiceAccount.name"
    value = "actions-runner-controller-gha-rs-controller"

  }

  set {
    name  = "template.spec.serviceAccountName"
    value = "actions-runner-controller-gha-rs-controller"

  }

}

resource "helm_release" "helm-arc-runners-customrole" {
  name             = "github-actions-roles"
  chart            = "${path.module}/github-actions-roles" # Specify the relative path to the Helm chart within the repo
  namespace        = "github"
  version          = "0.0.8"
  create_namespace = true

  set {
    name  = "service_account.name"
    value = "actions-runner-controller-gha-rs-controller"

  }

  set {
    name  = "service_account.namespace"
    value = "github"

  }
}
