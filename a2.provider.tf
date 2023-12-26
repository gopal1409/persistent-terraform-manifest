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
  }
  backend "s3" {
    bucket = "gopal140999"
    key = "vpcproject.tfstate"
    region = "us-east-1"
    dynamodb_table = "dev-project-vpc"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}