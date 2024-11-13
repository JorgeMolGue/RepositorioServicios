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
aws_access_key_id=ASIA2MS22DL2OAAARB7T
aws_secret_access_key=G8zzilGqBbUzvwojVEWmrJkfbve24eL6N0lF94Hj
aws_session_token=IQoJb3JpZ2luX2VjEFEaCXVzLXdlc3QtMiJHMEUCIHREykAnUp8GgwWFOxQvnatReh+6K1Hz8CN1JLPvnBn9AiEAlC67Ww2UJljrLRunY3fDjgpaygqrQnYS2BCspcT5QR0quAII2v//////////ARAAGgw3MTQyMjg3Njc0NzYiDEsWRfgdlNidkCp+4CqMAi0nYSmArcHU2xiIBJpaWUxE6sQNaIOBcaAisfSQbM9GZcEZMazK9D3grC4g27n5t21PsvxpwYPYdv1SuczygFCdQ0OvyvxQ0fVMvLD6FV3fZX4GzFK1kJgcy79duiQm4YeIBD389Ou9716D3HT5L3nFolzZpCpDZx898ZaBkwMWFQdDzVd/+ZfYnikbvQRlL2Cz4Ac+WK63AvmNNaIovYwxIPBw70uAQBp+ppFmF4HNMvyfhVVnLy8lBNlCo0GLs8zyvFeQOZIPdiULZzta1RCrlgLW7RCxjbsb2WELWwDfaXKO5tZjwBJ+2IyPurn1G514yZe4PqVZxkVxLopWeD4MN5IEw8L/ysX0ve8wqrnTuQY6nQH5gDENVgLsCscD9VEwiBJnCEzECMEkmItiMJMuQPszNfr4IkUO8R6HUjIFP7kvYO3mpnjy9gbW/65yw2upJQ3wwf7GLL3NVsPJXTO0sv6g1f4L2t2/Gk9hrX+H8JooYO4A0vzUmfbgYSwzuhU2pz2EM7jyADB7rDTqcPRCQWpqOQemXIGoqtNwaNnca/tSVcQ8dRSFlvaPFp2Jo1du
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
echo "EXPOSE 20 21 3040-3060" >> Dockerfile
echo "RUN useradd -m -s /bin/bash jorge && echo 'jorge:jorge' | chpasswd" >> Dockerfile
echo 'CMD ["proftpd", "--nodaemon"]' >> Dockerfile

Construir la imagen de Docker
sudo docker build -t myproftpd .

Ejecutar el contenedor de ProFTPD
sudo docker run -d --name proftpd -p 20:20 -p 21:21 -p 3041:3041 -p 3050:3050 -v /home/jorge/bucket:/home/jorge myproftpd
