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
aws_access_key_id=ASIA2MS22DL2HE3GE4UV
aws_secret_access_key=kyTMIcdUH7EhpjUmbYW23F0F1l9xeRYIrNRzen1X
aws_session_token=IQoJb3JpZ2luX2VjEA8aCXVzLXdlc3QtMiJHMEUCID2EwHhjYvz390jtdlUO1UKbDlvcorP072rm/8VIjomRAiEAjDKnu2+GsDuUZsU1nmmCeuANX0FffEHFiP86f2aXGVAquAIIqP//////////ARAAGgw3MTQyMjg3Njc0NzYiDIJkqKQfgcI3SsmpqCqMAr/XDfEExsGu9J2uABYXNjVuNmSR3mw978hfSG1ZE6OlddvxjgiDyRoaC38TxRqUyRS5OWJ/vMzBppqK0hfzjFGeY7FRjIb59xMT8jNs1SqScljy7lfPhcMfE6I0SelcRj8PfO0luoKq4PQAmPs3vIfefNfYCHlP86LaWQvV6NmObhtnGkepkUq/oi/SM0toiCswIrXqhl55PcDPOT0L97LwtqrWehR7wFKyorBNYv/vVhGYMSBfz1DBsUMg+mQQIViFOBCfDmbqCdKd/79T4mayuAdZCAmNATQHgp8QGRJJI3YxrTAbYlh8/TsKRlBwL9DfizOpaI4X5ZSusb9rXD4qFRkbljlRfUBhRHkw34b9uQY6nQFUpmOFEKddc36ujnOG+BBbmRkhYmqh1RqVMEZvs8PnhM+IGtSRSTUA2Ylkd/qzyjx4pwAbDP90LLTrlOPxpnx7GB6snzb6SIi/S7c9e7RlG/W5zCEN5R8ZwnEMpMJ3JANdyndgLp51UfnPwLFjuON/2tlYZSwC8f1aLTb4YK+b/qm+ggLwED2r8Ob3gj/XkmpVRYW0TNjRQ+xSFbSB
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

