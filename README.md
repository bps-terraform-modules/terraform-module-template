# test-terraform-repo
A test repository for Terraform module

editing
<!-- BEGIN_TF_DOCS -->


## Example

```hcl
module "example" {
  source  = "app.terraform.io/basspro/example/module"
  version = "1.1.0"

  example_id = "example-001"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_example_id"></a> [example\_id](#input\_example\_id) | A unique identifier for the resource | `string` | `"example-001"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | The ID of the null resource |  
<!-- END_TF_DOCS -->