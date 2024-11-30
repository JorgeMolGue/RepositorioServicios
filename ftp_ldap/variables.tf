variable "region" {
  description = "La región de AWS donde se crearán los recursos"
  default     = ""
}

variable "vpc1_cidr" {
  description = "CIDR para la VPC 1 (con subred pública y privada)"
  default     = ""
}

variable "vpc2_cidr" {
  description = "CIDR para la VPC 2 (con solo subred privada)"
  default     = ""
}
variable "public_subnet_cidr_vpc2" {
  description = "CIDR block for the public subnet in VPC 2"
  default     = ""
}

variable "public_subnet_vpc2_name" {
  description = "Name for the public subnet in VPC 2"
  default     = ""
}

variable "public_subnet_cidr" {
  description = "CIDR para la subred pública"
  default     = ""
}

variable "private_subnet_cidr" {
  description = "CIDR para la subred privada"
  default     = ""
}

variable "private_subnet_cidr_vpc2" {
  description = "CIDR para la subred privada de la VPC 2"
  default     = ""
}

variable "vpc1_name" {
  description = "Nombre de la VPC 1"
  default     = ""
}

variable "vpc2_name" {
  description = "Nombre de la VPC 2"
  default     = ""
}

variable "public_subnet_name" {
  description = "Nombre de la subred pública"
  default     = ""
}

variable "private_subnet_name" {
  description = "Nombre de la subred privada"
  default     = ""
}

variable "private_subnet_vpc2_name" {
  description = "Nombre de la subred privada de la VPC 2"
  default     = ""
}
##instancia
variable "instance_type" {
  description = "Tipo de la instancia EC2"
  default     = ""
}

variable "ami" {
  description = "ID de la AMI para la instancia"
  default     = "" 
}

variable "key_name" {
  description = "Nombre del par de claves para acceder a la instancia"
  default     = "" 
}

variable "bucket_name" {
  description = "Nombre del bucket S3"
  default     = ""
}
