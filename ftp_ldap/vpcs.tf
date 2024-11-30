# VPC 1 - Con subred pública y privada
resource "aws_vpc" "vpc1" {
  cidr_block = var.vpc1_cidr
  tags = {
    Name = var.vpc1_name
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, 0)

  tags = {
    Name = var.public_subnet_name
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = element(data.aws_availability_zones.available.names, 0)

  tags = {
    Name = var.private_subnet_name
  }
}

# VPC 2 - Con subred pública y privada
resource "aws_vpc" "vpc2" {
  cidr_block = var.vpc2_cidr
  tags = {
    Name = var.vpc2_name
  }
}

resource "aws_subnet" "private_subnet_vpc2" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = var.private_subnet_cidr_vpc2
  availability_zone = element(data.aws_availability_zones.available.names, 1)

  tags = {
    Name = var.private_subnet_vpc2_name
  }
}

resource "aws_subnet" "public_subnet_vpc2" {
  vpc_id                  = aws_vpc.vpc2.id
  cidr_block              = var.public_subnet_cidr_vpc2
  availability_zone       = element(data.aws_availability_zones.available.names, 1)
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_vpc2_name
  }
}

#peering
# Ruta de peering hacia VPC2
resource "aws_route" "route_to_vpc2" {
  route_table_id         = aws_route_table.public_route_table_vpc1.id
  destination_cidr_block = var.vpc2_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

# Peering entre VPCs
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = true

  tags = {
    Name = "Peering_VPC_1_to_VPC_2"
  }
}

# Ruta de peering en tabla privada de VPC2
resource "aws_route" "route_to_vpc1_private" {
  route_table_id         = aws_route_table.private_route_table_vpc2.id
  destination_cidr_block = var.vpc1_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}
