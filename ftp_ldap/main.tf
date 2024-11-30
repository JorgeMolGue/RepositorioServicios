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



# Bucket de S3
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  force_destroy = true
  tags = {
    Name = var.bucket_name
  }
}