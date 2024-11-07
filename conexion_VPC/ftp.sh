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
aws_access_key_id=ASIA2MS22DL2MHZBJMMU
aws_secret_access_key=uY40Bwi7p31diHDL1pZQO0FLDyhSnvFx1sSTBVlJ
aws_session_token=IQoJb3JpZ2luX2VjEMP//////////wEaCXVzLXdlc3QtMiJIMEYCIQCCDSKiKWfiY4VU+qtHAdP6YFWXUouV3dQENC6Zu6BMOAIhAP1lv2u+qvjRwPUM2UwIK6LvuQbOgIDtXaI9sxsdSUtWKq8CCEsQABoMNzE0MjI4NzY3NDc2Igxs68CvUwR175bu8okqjAIrFLM+Q9iiHc0ROdzTx0exxfj+aYwR/Bez3TW4aSjogDe2KqlmENSEqzOxk1EU2gd2zSKxyUKrucfdMf95Uh5xkmkSd+/rBYHBIVizOz53A01t4RjzS/RkdKkEbyZ8xJLO13OIpMrn8MPJhF/NJ0r9JqQmPm2zof5D6mTEEgsMDpSejd2C5LjB4x2aPwH1Pr6n0QXgE/Ncb9lb3mhVFrWC7357B3musmHRXrR4pszKpxQDEiUtgRUuGG/4pJy0Mfw/3I8EMUpshd17DHjw8onMf5V2gcl1SfPQj9YinkD+8X4e4xz2NavlxIoRoQTeYNnDwfTF7o/IcFCr1PI5KJW+4F5xgoe4k3dS4lFuMPKItLkGOpwBuQTdGEWF9WeZ53CjUUnvaeRtr7KftHA5CN1GnozwWMlEPH3S3WK2Ra0SRLWuxtvs9fqiMFM72w1J3y4KprRjEu2+FT7Hip7SNOBK9vURdJg9Xtex4WqpJemKK4y/Zj++l1VkYqsO0X+zGVgmRrkH6ZdPVZ41UkQAXJOYJMZD8PQrujoqIRHmvj4oGpJrnQRjqHR/a6W5eXvbdO+r
EOF
sudo mkdir prueba
sudo chmod 755 prueba	
sudo s3fs ftp-storage prueba


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
