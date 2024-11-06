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
sudo docker run -d --name proftpd -p 20:20 -p 21:21 -p 3041:3041 -p 3050:3050 myproftpd