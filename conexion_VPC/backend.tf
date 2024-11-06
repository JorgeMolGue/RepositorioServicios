terraform {
  backend "s3" {
    bucket = "artefacto-ftp"             # El nombre del bucket de S3
    key    = "terraform_state.tfstate"    # El nombre del archivo en S3
    region = "us-east-1"                  # La región del bucket S3
  }
}
