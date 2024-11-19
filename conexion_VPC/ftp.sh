#!/bin/bash
# Actualizar el repositorio e instalar Docker y s3fs
sudo apt-get update
sudo apt-get install -y docker.io
sudo apt-get install -y s3fs

# Iniciar servicio Docker
sudo systemctl start docker
sudo systemctl enable docker

# Crear Dockerfile para ProFTP
mkdir -p /home/admin/proftp
echo 'FROM debian:latest

# Instalar paquetes necesarios para ProFTP y LDAP
RUN apt-get update && apt-get install -y proftpd proftpd-mod-ldap ldap-utils
RUN apt-get install -y nano

# Configurar puertos pasivos de ProFTP
RUN echo "PassivePorts 3040 3060" >> /etc/proftpd/proftpd.conf

# Crear el usuario de FTP
RUN adduser --disabled-password --gecos "" jorge
RUN echo "jorge:jorge" | chpasswd

# Copiar el archivo de configuración de ProFTP
COPY proftpd.conf /etc/proftpd/proftpd.conf

# Establecer el comando para ejecutar ProFTP
CMD ["proftpd", "--nodaemon"]

# Exponer puertos FTP
EXPOSE 20 21 3040 3060' > /home/admin/proftp/Dockerfile

# Crear archivo de configuración de ProFTP con LDAP y acceso anónimo
cat <<EOF > /home/admin/proftp/proftpd.conf
<IfModule mod_ldap.c>
  LDAPServer "ldap://$LDAP_SERVER_IP"
  LDAPBaseDN "dc=example,dc=com"
  LDAPBindDN "cn=admin,dc=example,dc=com"
  LDAPPassword "password"
  LDAPUserFilter "(&(objectClass=inetOrgPerson)(uid=%u))"
  LDAPGroupFilter "(&(objectClass=posixGroup)(memberUid=%u))"
  LDAPUserNameAttribute "uid"
  LDAPGroupNameAttribute "cn"
  LDAPLogLevel 0
</IfModule>

PassivePorts 3040 3060

# Configuración para acceso anónimo
<Anonymous ~ftp>
    User ftp
    Group nogroup
    UserAlias anonymous ftp
    RequireValidShell off

    # El directorio accesible para el usuario anónimo será /home/jorge
    <Directory /home/jorge>
        <Limit WRITE>
            Deny All   # Deny write access to anonymous users
        </Limit>

        <Limit READ>
            Allow All   # Allow read access to anonymous users
        </Limit>
    </Directory>
</Anonymous>
EOF

# Crear archivo de credenciales de AWS
cd /home/admin
sudo mkdir .aws
sudo echo "[default]
aws_access_key_id=ASIA2MS22DL2EYKFFVFA
aws_secret_access_key=CNVtxQRQAdY+asTvna84sqBUwH7TwCEghS+fOb2D
aws_session_token=IQoJb3JpZ2luX2VjEOL//////////wEaCXVzLXdlc3QtMiJHMEUCIGcGG4iehvhDDSf/uo7Zhd9tlEdtdZaTQAcxLh0NvoEQAiEAwpzEk47dlLZZRCoCl2bhMqnTdknfOg2TCWCCnyzwOQsqrwIIehAAGgw3MTQyMjg3Njc0NzYiDKGWJaDD5oB7/dhooCqMAlI5Ypmo/j0o1t2PcIAgg6HNDiIAwiYDRh+qvpd3T4W8sjz0iydCW9av1MUmzggPEVLRiVIW5FYqhQvAUbMEpxNBiWpmXw2GMcZ9Zo4gEdhEs9Xm+sqxl5aD7wCSGDd0bgfxjJaG5mbjoVkrwVn8K9N7HQxWVelMSrk9mgRfnStXS/YdYwuI6TGZzn0hgMPvuc2Wl8YqCdQ8fPNMcYAZdHiPkymqX05DQnJ3+39hyQNTiyy2vbK3+9ONWyNnMghYBT8P2T3qF75ZAgGpKQPDUnExYRfEcK+Q5RRrd0tY7DN8ED4jolaCnEVeriEtm3dcnhg3eYVl1+tbFOJg0W9qG3U+Sqt2ch3sEZppKZ4w75DzuQY6nQFAgLEcu1mJ2Ok+/3oa3WMnlFOfJgQF3a3HAOFv8Qn5nAO8cn37VMEWkW83LHM6LM4LSDqOwpbAOF8iuOnbbBUADfr0Kc2731nVQ89mN8V7pMVuJU67PqUC0vw0i7mfepN3+tlPcjKX8Bj6bbPWhPuVWKoRahwtm71KL2jLnnGl30ib+KIuU2lPY4Pr+Jn7OVniNsgmXegyMx2tf7b8" > .aws/credentials
sudo mkdir -p /home/admin/carpeta_bucket
sudo mkdir -p /home/admin/ftp_bucket
sudo chmod 755 /home/admin/ftp_bucket
sudo mkdir -p /root/.aws
sudo cp /home/admin/.aws/credentials /root/.aws/credentials

# Montar el bucket S3
sudo s3fs proftpd-router /home/admin/ftp_bucket -o allow_other

# Crear el directorio /home/jorge para ser usado por el acceso FTP
sudo mkdir -p /home/jorge
sudo chown ftp:nogroup /home/jorge
sudo chmod 755 /home/jorge

# Construir y ejecutar el contenedor Docker con LDAP y configuración de ProFTP
cd /home/admin/proftp
sudo docker build -t proftp .
sudo docker run -d --name proftp -p 21:21 -p 20:20 -p 3041:3041 -p 3050:3050 -v /home/admin/ftp_bucket:/home/jorge proftp


