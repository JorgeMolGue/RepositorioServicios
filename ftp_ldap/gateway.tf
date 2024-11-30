# Elastic IP para NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "NAT_EIP"
  }
}

# NAT Gateway en la subred pública de VPC2
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_vpc2.id
  tags = {
    Name = "NAT_Gateway_VPC2"
  }
}

resource "aws_route" "private_to_nat" {
  route_table_id         = aws_route_table.private_route_table_vpc2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

# Internet Gateway para VPC1
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "InternetGateway_VPC1"
  }
}

# Internet Gateway para VPC2
resource "aws_internet_gateway" "igw_vpc2" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "InternetGateway_VPC2"
  }
}
