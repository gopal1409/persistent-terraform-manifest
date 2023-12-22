resource "aws_vpc" "this" {
  cidr_block = var.cidr
  enable_dns_support = true 
  enable_dns_hostnames = true 
  tags = {
   Name="app-vpc"
  }
}

##once we create vpc we will create subnet
resource "aws_subnet" "private" {
  count = length(var.subnet_cidr_private) #whole number 2
  vpc_id = aws_vpc.this.id 
  cidr_block = var.subnet_cidr_private[count.index]
  availability_zone = var.availability_zone[count.index]
   tags = {
    Name = "Server ${count.index}"
  }
}
###lets create a custom rtb
resource "aws_route_table" "this-rt" {
  vpc_id = aws_vpc.this.id 
  tags = {
    Name = "my-app-custom-rtb"
  }
}

###once i create the custom rtb i need to associate the same with all my subnet
resource "aws_route_table_association" "this-rt-assoc" {
  ###using this length function i found out what subnet i have
  count = length(var.subnet_cidr_private)
  #i need to do the iteration one by one
  subnet_id = element(aws_subnet.private.*.id,count.index)
  ###finally associate with all the rtb
  route_table_id = aws_route_table.this-rt.id 
}
###created an internet gw and attach the same with vpc
resource "aws_internet_gateway" "this-igw" {
  vpc_id = aws_vpc.this.id 
}
#ig need to be assoicate with the custom rtb we have created
resource "aws_route" "internet_route" {
    #provider destiation
  destination_cidr_block = "0.0.0.0/0"
  ####provider rtb id
  route_table_id = aws_route_table.this-rt.id
  #gatewayid 
  gateway_id =  aws_internet_gateway.this-igw.id 
}