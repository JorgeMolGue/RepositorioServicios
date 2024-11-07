variable "region" {
  description = "La región de AWS donde se crearán los recursos"
  default     = "us-east-1"
}

variable "vpc1_cidr" {
  description = "CIDR para la VPC 1 (con subred pública y privada)"
  default     = "192.168.244.0/24"
}

variable "vpc2_cidr" {
  description = "CIDR para la VPC 2 (con solo subred privada)"
  default     = "192.168.152.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR para la subred pública"
  default     = "192.168.244.0/25"
}

variable "private_subnet_cidr" {
  description = "CIDR para la subred privada"
  default     = "192.168.244.128/25"
}

variable "private_subnet_cidr_vpc2" {
  description = "CIDR para la subred privada de la VPC 2"
  default     = "192.168.152.128/25"
}

variable "vpc1_name" {
  description = "Nombre de la VPC 1"
  default     = "VPC-publica"
}

variable "vpc2_name" {
  description = "Nombre de la VPC 2"
  default     = "VPC-privada"
}

variable "public_subnet_name" {
  description = "Nombre de la subred pública"
  default     = "Subred-publica-vpc-publica"
}

variable "private_subnet_name" {
  description = "Nombre de la subred privada"
  default     = "Subred-privada-vpc-publica"
}

variable "private_subnet_vpc2_name" {
  description = "Nombre de la subred privada de la VPC 2"
  default     = "Subred-privada-vpc-privada"
}
##instancia
variable "instance_type" {
  description = "Tipo de la instancia EC2"
  default     = "t2.micro"
}

variable "ami" {
  description = "ID de la AMI para la instancia"
  default     = "ami-064519b8c76274859" 
}

variable "key_name" {
  description = "Nombre del par de claves para acceder a la instancia"
  default     = "ssh" 
}

variable "bucket_name" {
  description = "Nombre del bucket S3"
  default     = "ftp-storage-7142-2876-7476"
}

