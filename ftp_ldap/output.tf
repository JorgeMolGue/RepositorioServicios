
output "ftp_instance_public_ip" {
  description = "Dirección IP pública de la instancia FTP en VPC1"
  value       = aws_instance.ftp_instance.public_ip
}

output "bastion_instance_public_ip" {
  description = "Dirección IP pública de la instancia Bastión en VPC2"
  value       = aws_instance.bastion_instance.public_ip
}

output "ldap_instance_private_ip" {
  description = "Dirección IP privada de la instancia LDAP en VPC2"
  value       = aws_instance.ldap_instance.private_ip
}

output "s3_bucket_name" {
  description = "Nombre del bucket S3"
  value       = aws_s3_bucket.my_bucket.bucket
}

