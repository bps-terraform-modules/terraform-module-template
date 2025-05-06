variable "runner_name" {
  type        = string
  description = "Name of the runner scale set that will be used for targeting, ie a cluster name"
}

variable "github_urls" {
  type = list(object({
    name           = string
    url            = string
    key_vault_name = string
  }))
  description = "URL of organization or repo, ie https://github.com/bps-eai"
}
