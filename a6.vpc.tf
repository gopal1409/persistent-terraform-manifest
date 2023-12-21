resource "aws_vpc" "this" {
  cidr_block = "10.20.20.0/26"
  enable_dns_support = true 
  enable_dns_hostnames = true 
  tags = {
   Name="app-vpc"
  }
}

##once we create vpc we will create subnet
resource "aws_subnet" "private" {
  count = length(var.subnet_cidr_private)
  vpc_id = aws_vpc.this.id 
  cidr_block = var.subnet_cidr_private[count.index]
  availability_zone = var.availability_zone[count.index]
   tags = {
    Name = "Server ${count.index}"
  }
}