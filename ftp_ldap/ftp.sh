#!/bin/bash

sleep 20

# Actualizar el sistema
sudo apt-get update

# Instalar dependencias necesarias para Docker
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
sudo chown $USER:$USER ~/.aws
sudo cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id=ASIA2MS22DL2OS3CQ4QG
aws_secret_access_key=FTVFzLnaMFiIi3zLBRy5LWhG+6cfkKWnl0jKziiw
aws_session_token=IQoJb3JpZ2luX2VjEOf//////////wEaCXVzLXdlc3QtMiJIMEYCIQDRP6W9AItvntwWBUNYFrkdLB/8EvNODfHyMO55to5EogIhAOzkvl24I9L4846xee89s1S958TwyaR/rmR15uDins9eKrgCCJD//////////wEQABoMNzE0MjI4NzY3NDc2Igz0GUjyCIPdyf6Sx/MqjAJcqsPx4p5ENvkxUsGgQdwhwAQfcyQF2dR7PwgTBIuewNBfSntFeU5MMvB7g4Mf7ikmbRH+Px282WNq7uazJdGO/VXM68fk9vlLfaPBWTEMqATFHlhlNNL3DoicMen4rlj4XGtf8sUoJ8oXZkSxoh3HYAopU1c3cRun4pTG+amVkFAPs2WAZneM2gnoEse8BqVio7FcexeE88Fo4Ib19gafCYkI/s5CaZ7B8DhNMd1g5IVxp1besvyN9680TGTHzqZ/ntYcK4Os1VMKw8w9FzXZATEwjucGw58LgLzJj7L+5K0hW9jo9LdeMwhOrFrYBROAJuffzKrH2EGVpwdRINvnlWTeZkxftFW8nZKiMJ3CrLoGOpwBoq8skoSfDCfXBLbJBoGf6rtlextl2hrVRy1uLRIuYY3v2sGJz8wrTdOLcoF5/r/AXlrhBI9o9Fdr2c7ycHELmc8RqKjAkMuKPGiVXdUaCvaWfqVX1iZ9ctA70F/8b4uVLYarZfk0bnEeG4KTJL8kAb+CNxiXddRgUJvXHakXDztGaXJ23LmvEmw7eVQxEdlDe/5Sqx/sNbNNJtPd
EOF

# Montar el bucket S3 en el directorio del FTP
sudo s3fs ftp-storage-7142-2876-7476  /mnt/bucket-s3 -o allow_other

sudo apt install cron -y
# Crear directorio para el FTP
sudo mkdir -p /home/admin/ftp
sudo mkdir /mnt/bucket-s3
sudo chmod 777 /mnt/bucket-s3

# Habilitar cron para que se inicie automáticamente en el arranque
sudo systemctl enable cron
sudo apt update
sudo apt install cron -y
sudo apt install rsync -y
# Iniciar el servicio de cron si no está en ejecución
sudo systemctl start cron
sudo systemctl enable cron

# Añadir el cron job automáticamente si no existe
(crontab -l 2>/dev/null; echo "* * * * * rsync -av --remove-source-files /home/admin/ftp/ /mnt/bucket-s3/") | crontab -


# Crear directorio para el Dockerfile
mkdir -p /home/docker
cd /home/docker

# Crear el Dockerfile
cat > Dockerfile <<EOF
FROM debian:latest

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y proftpd openssl nano proftpd-mod-crypto proftpd-mod-ldap ldap-utils

# Instalar el módulo de criptografía de ProFTPD
RUN apt-get update && apt-get install -y proftpd-mod-crypto && apt-get install proftpd-mod-ldap -y
RUN useradd -m -s /bin/bash jorge && echo 'jorge:jorge' | chpasswd
RUN mkdir -p /home/admin/ftp && chown -R jorge:jorge /home/admin && chmod -R 777 /home/admin && chmod -R 777 /home/

# Generar el certificado SSL/TLS para ProFTPD
RUN openssl req -x509 -newkey rsa:2048 -sha256 -keyout /etc/ssl/private/proftpd.key -out /etc/ssl/certs/proftpd.crt -nodes -days 365 \
    -subj "/C=ES/ST=España/L=Granada/O=jorge/OU=jorge/CN=ftp.jorge.com"

# Eliminar el bloque de cuotas anterior de /etc/proftpd/proftpd.conf
RUN sed -i '/<IfModule mod_quotatab.c>/,/<\/IfModule>/d' /etc/proftpd/proftpd.conf

# Configuración de ProFTPD
RUN echo "DefaultRoot /home/admin/ftp" >> /etc/proftpd/proftpd.conf && \
    echo "Include /etc/proftpd/modules.conf" >> /etc/proftpd/proftpd.conf && \
    echo "LoadModule mod_ldap.c" >> /etc/proftpd/modules.conf && \
    echo "Include /etc/proftpd/ldap.conf" >> /etc/proftpd/proftpd.conf && \
    echo "Include /etc/proftpd/tls.conf" >> /etc/proftpd/proftpd.conf && \
    echo "PassivePorts 3040 3041" >> /etc/proftpd/proftpd.conf && \
    echo "<IfModule mod_tls.c>" >> /etc/proftpd/tls.conf && \
    echo "  TLSEngine on" >> /etc/proftpd/tls.conf && \
    echo "  TLSLog /var/log/proftpd/tls.log" >> /etc/proftpd/tls.conf && \
    echo "  TLSProtocol SSLv23" >> /etc/proftpd/tls.conf && \
    echo "  TLSRSACertificateFile /etc/ssl/certs/proftpd.crt" >> /etc/proftpd/tls.conf && \
    echo "  TLSRSACertificateKeyFile /etc/ssl/private/proftpd.key" >> /etc/proftpd/tls.conf && \
    echo "</IfModule>" >> /etc/proftpd/tls.conf && \
    echo "<Anonymous /home/admin/ftp>" >> /etc/proftpd/proftpd.conf && \
    echo "  User ftp" >> /etc/proftpd/proftpd.conf && \
    echo "  Group nogroup" >> /etc/proftpd/proftpd.conf && \
    echo "  UserAlias anonymous ftp" >> /etc/proftpd/proftpd.conf && \
    echo "  RequireValidShell off" >> /etc/proftpd/proftpd.conf && \
    echo "  MaxClients 10" >> /etc/proftpd/proftpd.conf && \
    echo "  <Directory *>" >> /etc/proftpd/proftpd.conf && \
    echo "    <Limit WRITE>" >> /etc/proftpd/proftpd.conf && \
    echo "      DenyAll" >> /etc/proftpd/proftpd.conf && \
    echo "    </Limit>" >> /etc/proftpd/proftpd.conf && \
    echo "  </Directory>" >> /etc/proftpd/proftpd.conf && \
    echo "</Anonymous>" >> /etc/proftpd/proftpd.conf && \
    echo " LoadModule mod_tls.c" >> /etc/proftpd/modules.conf

# Añadir configuración de cuotas a /etc/proftpd/proftpd.conf
RUN echo "<IfModule mod_quotatab.c>" >> /etc/proftpd/proftpd.conf && \
    echo "QuotaEngine on" >> /etc/proftpd/proftpd.conf && \
    echo "QuotaLog /var/log/proftpd/quota.log" >> /etc/proftpd/proftpd.conf && \
    echo "<IfModule mod_quotatab_file.c>" >> /etc/proftpd/proftpd.conf && \
    echo "     QuotaLimitTable file:/etc/proftpd/ftpquota.limittab" >> /etc/proftpd/proftpd.conf && \
    echo "     QuotaTallyTable file:/etc/proftpd/ftpquota.tallytab" >> /etc/proftpd/proftpd.conf && \
    echo "</IfModule>" >> /etc/proftpd/proftpd.conf && \
    echo "</IfModule>" >> /etc/proftpd/proftpd.conf

RUN cd /etc/proftpd
# Comandos ftpquota para crear tablas y registros
RUN cd /etc/proftpd && ftpquota --create-table --type=limit --table-path=/etc/proftpd/ftpquota.limittab && \
    ftpquota --create-table --type=tally --table-path=/etc/proftpd/ftpquota.tallytab && \
    ftpquota --add-record --type=limit --name=jorge --quota-type=user --bytes-upload=20 --bytes-download=400 --units=Mb --files-upload=15 --files-download=50 --table-path=/etc/proftpd/ftpquota.limittab && \
    ftpquota --add-record --type=tally --name=jorge --quota-type=user

# Configuración de LDAP en /etc/proftpd/proftpd.conf
RUN echo "<IfModule mod_ldap.c>" >> /etc/proftpd/proftpd.conf && \
    echo "    LDAPLog /var/log/proftpd/ldap.log" >> /etc/proftpd/proftpd.conf && \
    echo "    LDAPAuthBinds on" >> /etc/proftpd/proftpd.conf && \
    echo "    LDAPServer ldap://192.168.152.155:389" >> /etc/proftpd/proftpd.conf && \
    echo "    LDAPBindDN \"cn=admin,dc=jorgeftp,dc=com\" \"admin_password\"" >> /etc/proftpd/proftpd.conf && \
    echo "    LDAPUsers \"dc=jorgeftp,dc=com\" \"(uid=%u)\"" >> /etc/proftpd/proftpd.conf && \
    echo "</IfModule>" >> /etc/proftpd/proftpd.conf

# Configuración de LDAP en /etc/proftpd/ldap.conf
RUN echo "<IfModule mod_ldap.c>" >> /etc/proftpd/ldap.conf && \
    echo "    # Dirección del servidor LDAP" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPServer 192.168.152.155" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPBindDN \"cn=admin,dc=jorgeftp,dc=com\" \"admin_password\"" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPUsers ou=users,dc=jorgeftp,dc=com (uid=%u)" >> /etc/proftpd/ldap.conf && \
    echo "    CreateHome on 755" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPGenerateHomedir on 755" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPForceGeneratedHomedir on 755" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPGenerateHomedirPrefix /home" >> /etc/proftpd/ldap.conf && \
    echo "</IfModule>" >> /etc/proftpd/ldap.conf

RUN echo "<Directory /home/admin/ftp>" >> /etc/proftpd/proftpd.conf && \
    echo "<Limit WRITE>" >> /etc/proftpd/proftpd.conf && \
    echo "  DenyUser jose" >> /etc/proftpd/proftpd.conf && \
    echo "</Limit>" >> /etc/proftpd/proftpd.conf && \
    echo "</Directory>" >> /etc/proftpd/proftpd.conf 
# Exponer los puertos de FTP
EXPOSE 20 21 3040-3041

CMD ["sh", "-c", "chmod -R 777 /home/admin/ftp && proftpd --nodaemon"]


EOF

# Construir la imagen de Docker
docker build -t myproftpd .

# Ejecutar el contenedor
docker run -d --name proftpd -p 20:20 -p 21:21 -p 3040:3040 -p 3041:3041 -v /home/admin/ftp:/home/admin/ftp myproftpd

