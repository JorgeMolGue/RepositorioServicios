terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = var.region
}

# Obtener las zonas de disponibilidad
data "aws_availability_zones" "available" {}

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

# VPC 2 - Solo con subred privada
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

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "InternetGateway"
  }
}

# Tabla de rutas pública
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Asociación de la tabla de rutas con la subred pública
resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Instancia EC2
resource "aws_instance" "mi_instancia" {
  ami                    = var.ami
  instance_type         = var.instance_type
  key_name              = var.key_name
  subnet_id             = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data = file("ftp.sh")
  tags = {
    Name = "ftp"
  }
}

# Grupo de seguridad
resource "aws_security_group" "sg" {
  vpc_id      = aws_vpc.vpc1.id  # Asegúrate de que el grupo de seguridad está en la misma VPC que la subred
  name        = "mi-grupo-seguridad"
  description = "Grupo de seguridad para permitir SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 20
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3040
    to_port     = 3060
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir todo el tráfico de salida
  }
}

# Peering entre VPCs
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = true

  tags = {
    Name = "Peering_VPC_1_a_VPC_2"
  }
}

# Aceptar la conexión de peering en VPC 2
resource "aws_vpc_peering_connection_accepter" "accept" {
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  auto_accept               = true
}
