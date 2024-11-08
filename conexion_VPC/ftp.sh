#!/bin/bash

Actualizar el sistema
sudo apt-get update

Instalar las dependencias necesarias
sudo apt-get install -y ca-certificates curl

Agregar la clave GPG de Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

Agregar el repositorio de Docker a las fuentes de Apt
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

Actualizar los índices de paquetes
sudo apt-get update

sudo apt update
sudo apt install s3fs -y

sudo mkdir ~/.aws
sudo cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id=ASIA2MS22DL2AOFCDFXV
aws_secret_access_key=RZnVobOvAYtnHUoP+qeEeC0VH/px/4L+PEM8N4hc
aws_session_token=IQoJb3JpZ2luX2VjENP//////////wEaCXVzLXdlc3QtMiJGMEQCIEnSkO+Tcy9ghIiPcNKXFcdN8A5EXbK2VFm6d9tODmJMAiAVZ+IvNz1Iny2TryVArcuiEzvpD5i8VCXJSPDXXpdulyqvAghcEAAaDDcxNDIyODc2NzQ3NiIMhYqNmBiZOrZdYF4FKowCdF7Gxbu4iZJaiwjAhlF47+i3cmwmNeD3gOlTHjUTvFvddhU0zuu+WP6VvSYYFdfg2WlQVqx3w6PzYGBMQ9wfra/ppmMc5tkSoKf/UZNnrUOhyr2WaMzpfiZ1RVc49gAywywEqlCLU7r/EfB5mUouxiPTPk5ZQEOaxZz6y1WEn7lMrpn1y8HY8/fDhEJdkyIivm0Wl4gjKJC7AEGti8+prRQw9wJadtw+RIE8jNkhivQ0E9bN258WGp0MmtZXJaIgZ2o5jxSmnLiv9mHX2BaGdcBOTXdzJqV+IAo9ucPAWpj8rjeys1XS0eywJy+s2KlrJbMM+cbKy0fLNR8NxcObTkbWHcfyLEgJikhvgDCW37e5BjqeASp/odOuUTXlP3cEd7DFwPwg2vuzItaR7IX3aN1IkFRz7F9nt16DxvCix8qMfLyJrwDjRwEuopjWm6z/GUPIzerpMvjPGHJ6ecIzdjNoD6L06iC00kEJj2098TtiopfhK+/gLorxVon4v/gyucffa0U9d63lJdacX+v9CzKPsvbuOKTxaIUSbijggHjNrs0fRDnpSt3TUfpqqG6n9agz
EOF
sudo mkdir -p /home/jorge/bucket 
sudo chmod 755 /home/jorge/bucket 	
sudo s3fs ftp-storage-7142-2876-7476 /home/jorge/bucket -o allow_other

Instalar Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

Iniciar y habilitar el servicio de Docker
sudo systemctl start docker
sudo systemctl enable docker

Crear un directorio para Docker y un Dockerfile
mkdir -p /home/docker
cd /home/docker

Crear el Dockerfile
touch Dockerfile
echo "FROM debian:latest" >> Dockerfile
echo "RUN apt-get update && apt-get install -y proftpd && apt install nano -y " >> Dockerfile
echo "RUN echo 'DefaultRoot ~' >> /etc/proftpd/proftpd.conf" >> Dockerfile
echo "RUN echo 'PassivePorts 3040 3060' >> /etc/proftpd/proftpd.conf" >> Dockerfile
echo "RUN echo 'MasqueradeAddress 44.199.206.59' >> /etc/proftpd/proftpd.conf" >> Dockerfile
echo "EXPOSE 20 21 3040-3060" >> Dockerfile
echo "RUN useradd -m -s /bin/bash jorge && echo 'jorge:jorge' | chpasswd" >> Dockerfile
echo 'CMD ["proftpd", "--nodaemon"]' >> Dockerfile

Construir la imagen de Docker
sudo docker build -t myproftpd .

Ejecutar el contenedor de ProFTPD
sudo docker run -d --name proftpd -p 20:20 -p 21:21 -p 3041:3041 -p 3050:3050 -v /home/jorge/bucket:/home/jorge myproftpd
