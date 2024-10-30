

# Variables para la configuración de VPCs

variable "vpcs" {
  description = "Lista de CIDR para las VPCs"
  type        = list(string)
}

variable "subnets" {
  description = "Lista de CIDR para las subredes"
  type        = list(object({
    public_cidr  = string
    private_cidr = string
  }))
}

variable "availability_zone" {
  description = "Zona de disponibilidad"
  type        = string
}
