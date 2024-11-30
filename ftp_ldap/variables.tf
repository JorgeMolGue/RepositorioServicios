variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "aws_session_token" {
  type = string
}

variable "public_key" {
  description = "Clave pública SSH para acceder a la instancia"
  type        = string
}

variable "region" {
  description = "La región de AWS donde se crearán los recursos"
  type        = string
}

variable "vpc1_cidr" {
  description = "CIDR para la VPC 1 (con subred pública y privada)"
  type        = string
}

variable "vpc2_cidr" {
  description = "CIDR para la VPC 2 (con solo subred privada)"
  type        = string
}
variable "public_subnet_cidr_vpc2" {
  description = "CIDR block for the public subnet in VPC 2"
  type        = string
}

variable "public_subnet_vpc2_name" {
  description = "Name for the public subnet in VPC 2"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR para la subred pública"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR para la subred privada"
  type        = string
}

variable "private_subnet_cidr_vpc2" {
  description = "CIDR para la subred privada de la VPC 2"
  type        = string
}

variable "vpc1_name" {
  description = "Nombre de la VPC 1"
  type        = string
}

variable "vpc2_name" {
  description = "Nombre de la VPC 2"
  type        = string
}

variable "public_subnet_name" {
  description = "Nombre de la subred pública"
  type        = string
}

variable "private_subnet_name" {
  description = "Nombre de la subred privada"
  type        = string
}

variable "private_subnet_vpc2_name" {
  description = "Nombre de la subred privada de la VPC 2"
  type        = string
}
##instancia
variable "instance_type" {
  description = "Tipo de la instancia EC2"
  type        = string
}

variable "ami" {
  description = "ID de la AMI para la instancia"
  type        = string
}

variable "key_name" {
  description = "Nombre del par de claves para acceder a la instancia"
  type        = string
}

variable "bucket_name" {
  description = "Nombre del bucket S3"
  type        = string
}
