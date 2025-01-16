# AKS Github Runners
Deploys a scalable actions runner setup into AKS that supports both at the Organization and Repository level.

## Usage

1. Create a PAT from Github, https://github.com/settings/tokens
2. Store the PAT within our `bps-devops-kv` vault as a secret https://portal.azure.com/#@cabelas.onmicrosoft.com/resource/subscriptions/1c6cd62a-5175-4ae7-a655-a524541b2cb9/resourceGroups/bps-devops-secrets/providers/Microsoft.KeyVault/vaults/bps-devops-kv/overview
3. Ensure that PAT has access over the right organization/repo and SSO is configured
4. Implement HCL code outined below populating appropriate variables

	```hcl
	module "github-runners" {
		source       = "git@github.com:bps-cloudops/terraform-module-aks-github-runners.git?ref=v1.0.1"
		key_vault_name = "github-ar-bps-eai"
		runner_name = "aks-eai-nonprod"
		github_url = "https://github.com/bps-eai"

	}
	```

## Example of a workflow

1. Create a file in the root of your project under `.github/workflows/<job_name>.yml`

2. Copy/Paste following template and update as neccessary
	```yaml
	name: Deploy

	on:
	push:
		branches:
		- main # Adjust branch name as necessary

	jobs:
	deploy:
		runs-on: <runner_name>
		steps:
		- name: Checkout repository
		uses: actions/checkout@v3

		- name: Run shell command
		shell: bash
		run: |
			curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
			chmod +x kubectl
			mkdir -p ~/.local/bin
			mv ./kubectl ~/.local/bin/kubectl
			export PATH="$PATH:$HOME/.local/bin"

			kubectl get pods

	```

## Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| key\_vault\_name | Name of secret within the bps-devops-kv keyvault that houses the PAT for accessing the `github_url` | `string` |  | yes |
| runner\_name | Name of the runner deployment, as well as the name that will be used within Github. This is the name that you'll use to target your action to run on. A good idea is to use a value that references the cluster and the environment | `string` |  | yes |
| github\_url | URL of organization or Repo. ie, `https://github.com/bps-eai` | `string` | | yes |