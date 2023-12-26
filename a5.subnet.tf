
##now we will create the public sibnet 

resource "aws_subnet" "public_subnet" {

  count = 2
  vpc_id = aws_vpc.vpc.id 
  cidr_block = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true 
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.environment}-public-subnet"
  }
}
##we created private subnet
resource "aws_subnet" "private_subnet" {
  count = 2
  vpc_id = aws_vpc.vpc.id 
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.environment}-private-subnet"
  }
}

##this is the route table for public subnet which will ensure that any instance launched in public subnet will have internet access

###now before we create nat gw. 
resource "aws_eip" "elastic_ip" {
  tags = {
    Name = "${var.environment}-eip"
  }
}

