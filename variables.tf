variable "github_urls" {
  type = list(object({
    name           = string
    url            = string
    key_vault_name = string
  }))
  description = "URL of organization or repo, ie https://github.com/bps-eai"
}
