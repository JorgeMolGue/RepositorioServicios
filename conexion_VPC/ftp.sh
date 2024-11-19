#!/bin/bash

# Actualizar el sistema
sudo apt-get update

# Instalar las dependencias necesarias
sudo apt-get install -y ca-certificates curl

# Agregar la clave GPG de Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Agregar el repositorio de Docker a las fuentes de Apt
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar los índices de paquetes
sudo apt-get update

# Instalar s3fs
sudo apt install s3fs -y

# Crear el directorio y archivo de credenciales de AWS
sudo mkdir -p ~/.aws
sudo cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id=ASIA2MS22DL2EYKFFVFA
aws_secret_access_key=CNVtxQRQAdY+asTvna84sqBUwH7TwCEghS+fOb2D
aws_session_token=IQoJb3JpZ2luX2VjEOL//////////wEaCXVzLXdlc3QtMiJHMEUCIGcGG4iehvhDDSf/uo7Zhd9tlEdtdZaTQAcxLh0NvoEQAiEAwpzEk47dlLZZRCoCl2bhMqnTdknfOg2TCWCCnyzwOQsqrwIIehAAGgw3MTQyMjg3Njc0NzYiDKGWJaDD5oB7/dhooCqMAlI5Ypmo/j0o1t2PcIAgg6HNDiIAwiYDRh+qvpd3T4W8sjz0iydCW9av1MUmzggPEVLRiVIW5FYqhQvAUbMEpxNBiWpmXw2GMcZ9Zo4gEdhEs9Xm+sqxl5aD7wCSGDd0bgfxjJaG5mbjoVkrwVn8K9N7HQxWVelMSrk9mgRfnStXS/YdYwuI6TGZzn0hgMPvuc2Wl8YqCdQ8fPNMcYAZdHiPkymqX05DQnJ3+39hyQNTiyy2vbK3+9ONWyNnMghYBT8P2T3qF75ZAgGpKQPDUnExYRfEcK+Q5RRrd0tY7DN8ED4jolaCnEVeriEtm3dcnhg3eYVl1+tbFOJg0W9qG3U+Sqt2ch3sEZppKZ4w75DzuQY6nQFAgLEcu1mJ2Ok+/3oa3WMnlFOfJgQF3a3HAOFv8Qn5nAO8cn37VMEWkW83LHM6LM4LSDqOwpbAOF8iuOnbbBUADfr0Kc2731nVQ89mN8V7pMVuJU67PqUC0vw0i7mfepN3+tlPcjKX8Bj6bbPWhPuVWKoRahwtm71KL2jLnnGl30ib+KIuU2lPY4Pr+Jn7OVniNsgmXegyMx2tf7b8
EOF

# Crear un directorio para montar el bucket S3
sudo mkdir -p /home/jorge/archivos_ftp
sudo chmod 755 /home/jorge/archivos_ftp
sudo s3fs ftp-storage-7142-2876-7476 /home/jorge/archivos_ftp -o allow_other

# Instalar Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Iniciar y habilitar el servicio de Docker
sudo systemctl start docker
sudo systemctl enable docker

# Crear un directorio para Docker y el Dockerfile
mkdir -p /home/docker
cd /home/docker

# Crear el Dockerfile para ProFTP
cat <<EOF > Dockerfile
FROM debian:latest
RUN apt-get update && apt-get install -y proftpd nano
RUN echo 'DefaultRoot ~' >> /etc/proftpd/proftpd.conf
RUN echo 'PassivePorts 3040 3060' >> /etc/proftpd/proftpd.conf
EXPOSE 20 21 3040-3060
RUN useradd -m -s /bin/bash jorge && echo 'jorge:jorge' | chpasswd
RUN echo '<Anonymous /home/jorge/archivos_ftp>' >> /etc/proftpd/proftpd.conf && \
    echo '  User ftp' >> /etc/proftpd/proftpd.conf && \
    echo '  Group nogroup' >> /etc/proftpd/proftpd.conf && \
    echo '  UserAlias anonymous ftp' >> /etc/proftpd/proftpd.conf && \
    echo '  RequireValidShell no' >> /etc/proftpd/proftpd.conf && \
    echo '  <Directory /home/jorge/archivos_ftp>' >> /etc/proftpd/proftpd.conf && \
    echo '    <Limit WRITE>' >> /etc/proftpd/proftpd.conf && \
    echo '      Deny All' >> /etc/proftpd/proftpd.conf && \
    echo '    </Limit>' >> /etc/proftpd/proftpd.conf && \
    echo '  </Directory>' >> /etc/proftpd/proftpd.conf && \
    echo '</Anonymous>' >> /etc/proftpd/proftpd.conf
CMD ["proftpd", "--nodaemon"]
EOF

# Construir la imagen de Docker
sudo docker build -t myproftpd .

# Ejecutar el contenedor de ProFTPD
sudo docker run -d --name proftpd -p 20:20 -p 21:21 -p 3041:3041 -p 3050:3050 -v /home/jorge/archivos_ftp:/home/jorge myproftpd

