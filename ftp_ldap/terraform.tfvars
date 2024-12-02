# Asignaciones de variables
region = "us-east-1"

# CIDR para las VPCs
vpc1_cidr = "192.168.244.0/24"
vpc2_cidr = "192.168.152.0/24"

# CIDR para las subredes
public_subnet_cidr = "192.168.244.0/25"        # Subred pública de VPC 1
private_subnet_cidr = "192.168.244.128/25"      # Subred privada de VPC 1
private_subnet_cidr_vpc2 = "192.168.152.128/25" # Subred privada de VPC 2
public_subnet_cidr_vpc2 = "192.168.152.0/25"    # Subred publica de VPC 2

# Nombres de las VPCs
vpc1_name = "VPC-publica"
vpc2_name = "VPC-privada"

# Nombres de las subredes
public_subnet_name = "Subred-publica-vpc-publica"
private_subnet_name = "Subred-privada-vpc-publica"
private_subnet_vpc2_name = "Subred-privada-vpc-privada"
public_subnet_vpc2_name  = "public-subnet-vpc2"

#instancia
instance_type = "t2.micro"
ami = "ami-064519b8c76274859"  # Cambia a la AMI que desees usar
key_name = "inst_key"       # Asegúrate de que el par de claves ya exista en la región


#bucket
bucket_name = "copias_router_jorge_molina"
