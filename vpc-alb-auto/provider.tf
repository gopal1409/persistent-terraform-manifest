##we will create the terraform provider 
##who is the provider
##aws we will create aws provider. 
##3how to get the provider setting. 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" ###this version number of optional but recommended in production
    }
    random = {
      source = "hashicorp/random"
     # version = "~> 3.0"
    } 
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "random_pet" "this" {
  length = 2
}