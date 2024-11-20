#!/bin/bash

# Actualizar el sistema
sudo apt-get update

# Instalar dependencias necesarias
sudo apt-get install -y ca-certificates curl

# Agregar la clave GPG de Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Agregar el repositorio de Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar los índices de paquetes e instalar Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Instalar s3fs
sudo apt update
sudo apt install s3fs -y

# Configurar credenciales de AWS
sudo mkdir -p ~/.aws
sudo cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id=ASIA2MS22DL2GSFX4K62
aws_secret_access_key=mBL/6bo8ZeNCBciig3mdLrBHzOVOAGztLlqQ8JkC
aws_session_token=IQoJb3JpZ2luX2VjEPH//////////wEaCXVzLXdlc3QtMiJIMEYCIQCsb7JjwGcWzbHuMulbtcTJUt5LfCfMh8t45f5dScbNUgIhAISu4mi4WydxCaCOwDFF0w1fs1PSDjx9QpI9PMjdeGQYKrgCCIr//////////wEQABoMNzE0MjI4NzY3NDc2Igx60HZmgU8zPNBCuh8qjALgxvOx+K5LCRHvLMbK94bPoOkdpepB9ma6pjYeldtM8mmYLgL1OfSprMYDBAUscTSDOrzCJVgClM/7hyxFcpVdLP2D88cMUowgV4ub7RsVeevIH/vpZi9NpXlklWkR1kyT+zUdD4QhKvMLavtoF6CGMnHNj0Ihj85Xz2KTWLjxgbl7CDY9UBQ4nOXKUsoI98ROKM6P1pnNBIOS6pYG2vLjZIshJ2vq1zPpxlTSzSSK2tVwPZ7NQ/kmn0KBRO+sLbq+HAuoSAGjc5qGP4ZZQ2UKUclsgmelgWc7IsKQJi/M4afmrx/M9hesogyBs7wwpymGMI/uWeHDMRywYtqd5jlM9usd0r6pvanqf1grMIHB9rkGOpwBuXF66PPS67be+eSbTEGuR09dOgzBWQv7Med6e4KdlYTKN+ker8B0gkkAKR0gzXlPR8WGGKIxKsjIo1nxrwGX8sCyI2zZbl+ZkWf8xPFoRqGn6GV9CyqmX5Foaxu7TnarOvg9Dr3ExQ6VTGDtQflgJaLdslzXuqKl1dMNjNBxEBj9dd4YEbTI7+q7hkS9L0IDWauF78/hWTlKfZ0k
EOF

# Crear directorio para el FTP
sudo mkdir -p /home/admin/ftp
sudo chmod 755 /home/admin/ftp

# Montar el bucket S3 en el directorio del FTP
sudo s3fs ftp-storage-7142-2876-7476 /home/admin/ftp -o allow_other

# Crear directorio para el Dockerfile
mkdir -p /home/docker
cd /home/docker

# Crear el Dockerfile
cat > Dockerfile <<EOF
FROM debian:latest
RUN apt-get update && apt-get install -y proftpd nano
RUN echo "DefaultRoot /home/admin/ftp" >> /etc/proftpd/proftpd.conf && \\
    echo "PassivePorts 3040 3060" >> /etc/proftpd/proftpd.conf && \\
    echo "<Anonymous /home/admin/ftp>" >> /etc/proftpd/proftpd.conf && \\
    echo "  User ftp" >> /etc/proftpd/proftpd.conf && \\
    echo "  Group nogroup" >> /etc/proftpd/proftpd.conf && \\
    echo "  UserAlias anonymous ftp" >> /etc/proftpd/proftpd.conf && \\
    echo "  RequireValidShell off" >> /etc/proftpd/proftpd.conf && \\
    echo "  MaxClients 10" >> /etc/proftpd/proftpd.conf && \\
    echo "  <Directory *>" >> /etc/proftpd/proftpd.conf && \\
    echo "    <Limit WRITE>" >> /etc/proftpd/proftpd.conf && \\
    echo "      DenyAll" >> /etc/proftpd/proftpd.conf && \\
    echo "    </Limit>" >> /etc/proftpd/proftpd.conf && \\
    echo "  </Directory>" >> /etc/proftpd/proftpd.conf && \\
    echo "</Anonymous>" >> /etc/proftpd/proftpd.conf
EXPOSE 20 21 3040-3060
RUN useradd -m -s /bin/bash jorge && echo 'jorge:jorge' | chpasswd
CMD ["proftpd", "--nodaemon"]
EOF

# Construir la imagen de Docker
sudo docker build -t myproftpd .

# Ejecutar el contenedor
sudo docker run -d --name proftpd -p 20:20 -p 21:21 -p 3040-3060:3040-3060 -v /home/admin/ftp:/home/admin/ftp myproftpd

