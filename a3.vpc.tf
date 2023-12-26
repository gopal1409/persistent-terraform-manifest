resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "MYVPC"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}