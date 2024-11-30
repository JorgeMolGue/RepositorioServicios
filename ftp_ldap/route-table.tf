
# Tablas de rutas para VPC1
resource "aws_route_table" "public_route_table_vpc1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "PublicRouteTable_VPC1"
  }
}

# Ruta hacia Internet en la tabla de rutas pública de VPC1
resource "aws_route" "route_to_internet_vpc1" {
  route_table_id         = aws_route_table.public_route_table_vpc1.id
  destination_cidr_block = "0.0.0.0/0" 
  gateway_id             = aws_internet_gateway.igw.id
}



resource "aws_route_table" "private_route_table_vpc1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "PrivateRouteTable_VPC1"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table_vpc1.id
}

resource "aws_route_table_association" "private_route_table_association_vpc1" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table_vpc1.id
}

# Tablas de rutas para VPC2
resource "aws_route_table" "public_route_table_vpc2" {
  vpc_id = aws_vpc.vpc2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc2.id
  }

  tags = {
    Name = "PublicRouteTable_VPC2"
  }
}

resource "aws_route_table" "private_route_table_vpc2" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "PrivateRouteTable_VPC2"
  }
}

resource "aws_route_table_association" "public_route_table_association_vpc2" {
  subnet_id      = aws_subnet.public_subnet_vpc2.id
  route_table_id = aws_route_table.public_route_table_vpc2.id
}

resource "aws_route_table_association" "private_route_table_association_vpc2" {
  subnet_id      = aws_subnet.private_subnet_vpc2.id
  route_table_id = aws_route_table.private_route_table_vpc2.id
}
