variable "instance_type" {
type = string
  default = "t2.micro"
}

variable "vpc_cidr" {
  type = string
  default = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
   type = list(string)
  default = ["10.10.0.0/24","10.10.2.0/24"]
}


variable "private_subnet_cidr" {
   type = list(string)
  default = ["10.10.3.0/24","10.10.4.0/24"]
}

variable "environment" {
  type = string 
  default = "dev-environment"
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}