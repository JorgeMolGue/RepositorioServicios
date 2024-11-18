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
aws_access_key_id=ASIA2MS22DL2PGXED72J
aws_secret_access_key=6CB0TeX0KZaQzLjuAGBk3H86qNs8uieMMvUh4CEh
aws_session_token=IQoJb3JpZ2luX2VjEMn//////////wEaCXVzLXdlc3QtMiJHMEUCIHlJom18fpK1lt/MjXumr2fkw3Y1fhMFcqCyO8rUyeJ6AiEAvpZ6PYczz9aczih0ohFuKQBaESmxEJTzlNdM7/ZhH98qrwIIYhAAGgw3MTQyMjg3Njc0NzYiDH8j4envlaxuD9TX2yqMAjmcdsY7H6c8CQzVwPYEwRyGX6RuggjRDHf2et0WuZYJT64AC11QCSQ9/uktRnnpD1WP/7i1lH0fw72D2Z6tcAMPapcZiN4Giz0qm7tR8Q/sqjWKKm20DxdrcHYUVAluxHbVScm2TitIv+oGcejI93kkrmH2w3/kD9OJEvi3PDybKs/Q/epj3/eW15IFwyqPb4iC0nbHNGFsRz79Kzp2tasfy8phw8/+lvWqOgWwXR+l4vKZcq5KxkwchBAzLW1U0F1pgCmh6dOP05VwyaI3YpTMk7m3EKIcSjkXAjKtQn+nIL3oHhesDtpMjJCaDmc3d48HkhJ5hcIBNx9/qzPmoBrRDyQPUtTcWd4HTN4w79ftuQY6nQEXdo/Q2ITZhYjb22SC9OLhjNizofsppgfa8tE3wIHeYm3t5TlSqnxi1QwkpDqBSwf9Od4HeK8NBbCCaGYuZd5grHGKNuDhY2Aa9eselhBYN92XyOJFXh8YGLuZb/2hAvXYlyXwqmyC7rkDQObShG4iQQqNWkgyE05cFVSjbyr+GPoTazO+DPBfJc/c0QDG7hXDw0Pr2uxrh6aP4bd3
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
echo "RUN echo 'DefaultRoot /home/jorge/bucket' >> /etc/proftpd/proftpd.conf" >> Dockerfile
echo "RUN echo 'PassivePorts 3040 3060' >> /etc/proftpd/proftpd.conf" >> Dockerfile
echo "EXPOSE 20 21 3040-3060" >> Dockerfile
echo "RUN useradd -m -s /bin/bash jorge && echo 'jorge:jorge' | chpasswd" >> Dockerfile
echo 'CMD ["proftpd", "--nodaemon"]' >> Dockerfile

Construir la imagen de Docker
sudo docker build -t myproftpd .

Ejecutar el contenedor de ProFTPD
sudo docker run -d --name proftpd -p 20:20 -p 21:21 -p 3041:3041 -p 3050:3050 -v /home/jorge/bucket:/home/jorge/bucket myproftpd
