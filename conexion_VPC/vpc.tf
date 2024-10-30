terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "us-east-1" 
}


# Primera VPC (VPC-1 con subred pública y privada)
resource "aws_vpc" "vpc_1" {
  cidr_block           = var.vpcs[0]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-1"
  }
}

# Segunda VPC (VPC-2 con solo subred privada)
resource "aws_vpc" "vpc_2" {
  cidr_block           = var.vpcs[1]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-2"
  }
}

# Subred pública en VPC-1
resource "aws_subnet" "public_subnet_vpc1" {
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = var.subnets[0].public_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
  tags = {
    Name = "Public Subnet VPC-1"
  }
}

# Subred privada en VPC-1
resource "aws_subnet" "private_subnet_vpc1" {
  vpc_id            = aws_vpc.vpc_1.id
  cidr_block        = var.subnets[0].private_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "Private Subnet VPC-1"
  }
}

# Subred privada en VPC-2
resource "aws_subnet" "private_subnet_vpc2" {
  vpc_id            = aws_vpc.vpc_2.id
  cidr_block        = var.subnets[1].private_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "Private Subnet VPC-2"
  }
}

# Gateway de Internet para VPC-1 (necesario para la subred pública)
resource "aws_internet_gateway" "igw_vpc1" {
  vpc_id = aws_vpc.vpc_1.id
  tags = {
    Name = "Internet Gateway VPC-1"
  }
}

# Tabla de enrutamiento para la subred pública en VPC-1
resource "aws_route_table" "public_route_table_vpc1" {
  vpc_id = aws_vpc.vpc_1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc1.id
  }
  tags = {
    Name = "Public Route Table VPC-1"
  }
}

# Asociación de la subred pública con la tabla de enrutamiento
resource "aws_route_table_association" "public_subnet_association_vpc1" {
  subnet_id      = aws_subnet.public_subnet_vpc1.id
  route_table_id = aws_route_table.public_route_table_vpc1.id
}

# Tabla de enrutamiento privada para VPC-1
resource "aws_route_table" "private_route_table_vpc1" {
  vpc_id = aws_vpc.vpc_1.id
  tags = {
    Name = "Private Route Table VPC-1"
  }
}

# Asociación de la subred privada con la tabla de enrutamiento privada en VPC-1
resource "aws_route_table_association" "private_subnet_association_vpc1" {
  subnet_id      = aws_subnet.private_subnet_vpc1.id
  route_table_id = aws_route_table.private_route_table_vpc1.id
}

# Tabla de enrutamiento privada para VPC-2
resource "aws_route_table" "private_route_table_vpc2" {
  vpc_id = aws_vpc.vpc_2.id
  tags = {
    Name = "Private Route Table VPC-2"
  }
}

# Asociación de la subred privada con la tabla de enrutamiento privada en VPC-2
resource "aws_route_table_association" "private_subnet_association_vpc2" {
  subnet_id      = aws_subnet.private_subnet_vpc2.id
  route_table_id = aws_route_table.private_route_table_vpc2.id
}

# Configuración de Peering entre VPC-1 y VPC-2
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id        = aws_vpc.vpc_1.id
  peer_vpc_id   = aws_vpc.vpc_2.id
  auto_accept   = true
  tags = {
    Name = "VPC Peering between VPC-1 and VPC-2"
  }
}

# Ruta para permitir el tráfico hacia VPC-2 desde VPC-1
resource "aws_route" "route_to_vpc2" {
  route_table_id         = aws_route_table.private_route_table_vpc1.id
  destination_cidr_block = aws_vpc.vpc_2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

# Ruta para permitir el tráfico hacia VPC-1 desde VPC-2
resource "aws_route" "route_to_vpc1" {
  route_table_id         = aws_route_table.private_route_table_vpc2.id
  destination_cidr_block = aws_vpc.vpc_1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}
