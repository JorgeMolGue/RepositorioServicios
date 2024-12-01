resource "aws_key_pair" "inst_key" { 
  key_name = var.key_name
  public_key = var.public_key 
}

# Instancia FTP en VPC1
resource "aws_instance" "ftp_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = aws_key_pair.inst_key.key_name
  vpc_security_group_ids = [aws_security_group.ftp_sg.id]
  user_data              = file("ftp.sh")

  tags = {
    Name = "FTPInstance"
  }
}

resource "aws_security_group" "ftp_sg" {
  vpc_id      = aws_vpc.vpc1.id
  name        = "ftp-sg"
  description = "Security group for FTP Instance"

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

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instancia Bastión en VPC2
resource "aws_instance" "bastion_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet_vpc2.id
  key_name               = aws_key_pair.inst_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "BastionInstance"
  }
}

resource "aws_security_group" "bastion_sg" {
  vpc_id      = aws_vpc.vpc2.id
  name        = "bastion-sg"
  description = "Security group for Bastion Instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instancia LDAP en subred privada de VPC2
resource "aws_instance" "ldap_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_vpc2.id
  key_name               = aws_key_pair.inst_key.key_name
  vpc_security_group_ids = [aws_security_group.ldap_sg.id]
  user_data              = file("ldap.sh")
  private_ip             = "192.168.152.155"
  depends_on             = [aws_nat_gateway.nat_gateway]
  tags = {
    Name = "LDAPInstance"
  }
}

resource "aws_security_group" "ldap_sg" {
  vpc_id      = aws_vpc.vpc2.id
  name        = "ldap-sg"
  description = "Security group for LDAP Instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.152.0/25"]
  }

  ingress {
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
