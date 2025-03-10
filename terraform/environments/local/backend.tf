terraform {
  backend "local" {
    path = "../../../localstack/.terraform/terraform.tfstate"
  }
} 