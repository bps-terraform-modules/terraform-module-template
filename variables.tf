variable "key_vault_name" {
  type        = string
  description = "Name of secret in the bps devops key vault"
}

variable "runner_name" {
  type        = string
  description = "Name of the runner scale set that will be used for targeting, ie a cluster name"
}

variable "github_url" {
  type        = string
  description = "URL of organization or repo, ie https://github.com/bps-eai"
}