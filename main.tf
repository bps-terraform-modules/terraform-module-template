resource "null_resource" "example" {
  triggers = {
    id = var.example_id
  }
}