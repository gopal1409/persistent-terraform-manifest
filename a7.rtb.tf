##lets create the internet gw first
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id 
  tags = {
    Name = "Internet GW"
  }
}

resource "aws_route_table" "Public_route_tables" {
  vpc_id = aws_vpc.vpc.id 
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

 tags = {
    Name = "${var.environment}-pub-rtb"
  }
}

###associate public rtb with public subnet 
resource "aws_route_table_association" "public_rt_assoc" {
  count = 2
  subnet_id = aws_subnet.public_subnet[count.index].id 
  route_table_id = aws_route_table.Public_route_tables.id
}

##lets create the natgw
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id 
  subnet_id = aws_subnet.public_subnet[0].id 
  depends_on = [ aws_internet_gateway.internet_gateway ]
   tags = {
    Name = "${var.environment}-natgw"
  }
}
###private_rtb
resource "aws_route_table" "private_route_tables" {
  vpc_id = aws_vpc.vpc.id 
  route  {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

 tags = {
    Name = "${var.environment}-nat-rtb"
  }
}
####associate the natgw with private subnet

resource "aws_route_table_association" "private_rt_assoc" {
  count = 2
  subnet_id = aws_subnet.private_subnet[count.index].id 
  route_table_id = aws_route_table.private_route_tables.id
}