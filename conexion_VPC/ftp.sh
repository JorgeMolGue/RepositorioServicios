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
aws_access_key_id=ASIA2MS22DL2FJ7YJBFH
aws_secret_access_key=H9xLj/QWl7bYqJHw2gaT5LPAuUD5yj4faegwk5TK
aws_session_token=IQoJb3JpZ2luX2VjEPr//////////wEaCXVzLXdlc3QtMiJGMEQCIGUhgXllkec15nR74xolbNu7JRGJVQFGCJ+tYsYlFjoWAiBM11FYU+NwriImrqaNl7ZEpSBLFaGJHen+xzMhS7KhZyq4AgiT//////////8BEAAaDDcxNDIyODc2NzQ3NiIMLMxeudWEV9ceiwLFKowCbsU9w0HMzGmEY/HUYUzTGxrFqa0F4Ol3AJNKzBrsFW1B9cXBKp1TwrP9dYs/nRhsCM78svMrn8pMdQyyLSVFmMtjClHdWqTzMcWlBdeJilITuuSEOZe5NSAMdw6JtnE10FmIYhRN+2jH2oGm+tK/+7+WHSEi9BM+/+isOodRiX3hbfJKmNHFmSr7OG8eIXZ1mXehhR0rR4dcg+VNVK3OENPzJeYIXL8sBqOsKERaelIiI6s3vO5EG3PLsTtAFXfkFIUe2z9MX2h22M/30+rKwMOv9kGRdGAklPmSph/Z3XSoGq4ko1fl71QQd+NFlXeYGmvr1stjec1on35kBUy+sBd6v5Zr3XR3YWw3TzD3wvi5BjqeAQviGH/Z4Lh0pNgzLQl3JrxaxHGdIYBNVnzcb58Wf7TUuNiZdrlPy1Vp77bRODiDRyzZ1ktscIl89JigOTHfc/FF+FuYirk3T1I0XlfFT87ZbBnMAGvqVngg/Q43f4PK9d6JT9lc9o28GBsw5PTiJIJ3jDonRG9VZs43EaummLGYr3/kqpDbORv7XNjlHZAGRRhk83sEWQPrPpB4hjBB
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

