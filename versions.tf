terraform {
  required_version = "~> 0.12.28"
  required_providers {
    aws = "~> 3.4.0"
  }
  backend "s3" {
    bucket                  = "benone-terraform-state-1"
    key                     = "workspace-develop/terraform.tfstate"
    region                  = "us-east-1"
    dynamodb_table          = "benone-terraform-locks"
    encrypt                 = true
    profile                 = "default"
    shared_credentials_file = "$HOME/.aws/credentials"
  }
}