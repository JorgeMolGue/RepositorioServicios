#!/bin/bash
sleep 50
# Actualiza el sistema e instala Docker y Docker Compose
sudo apt-get update -y
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Crea el directorio para los archivos de configuración
mkdir -p /home/admin/ldap

# Crea el archivo docker-compose.yml
cat << 'EOT' > /home/admin/ldap/Dockerfile

# Usar la imagen base de osixia/openldap
FROM osixia/openldap:1.5.0
# Copiar archivo LDIF para agregar usuarios y estructura


# Configurar variables de entorno para el dominio y la contraseña
ENV LDAP_ORGANISATION="jorge FTP"
ENV LDAP_DOMAIN="jorgeftp.com"
ENV LDAP_ADMIN_PASSWORD="admin_password"

# Configurar el contenedor para cargar el archivo LDIF al inicio


EOT

# Crea el archivo users.ldif
cat << 'EOF' > /home/admin/ldap/bootstrap.ldif

# Unidad organizativa para usuarios
dn: ou=users,dc=jorgeftp,dc=com
objectClass: top
objectClass: organizationalUnit
ou: users

# Usuario: jose
dn: uid=jose,ou=users,dc=jorgeftp,dc=com
objectClass: inetOrgPerson
objectClass: posixAccount
cn: jose
sn: Perez
uid: jose
mail: jose@jorgeftp.com
userPassword: jose
uidNumber: 1001
gidNumber: 1001
homeDirectory: /home/ftp/
loginShell: /bin/bash

# Usuario: pepe
dn: uid=pepe,ou=users,dc=jorgeftp,dc=com
objectClass: inetOrgPerson
objectClass: posixAccount
cn: pepe
sn: Garcia
uid: pepe
mail: pepe@jorgeftp.com
userPassword: pepe
uidNumber: 1002
gidNumber: 1002
homeDirectory: /home/ftp/
loginShell: /bin/bash

EOF

cd /home/admin/ldap
docker build -t myldap .

# Ejecutar el contenedor con registro en modo debug
docker run -d -p 389:389 -p 636:636 --name ldap myldap --loglevel debug

# Esperar unos segundos para que el servicio LDAP esté listo
sleep 10

# Copiar el archivo LDIF al contenedor
docker cp bootstrap.ldif ldap:/tmp

# Agregar la configuración desde el archivo LDIF
docker exec ldap ldapadd -x -D "cn=admin,dc=jorgeftp,dc=com" -w admin_password -f /tmp/bootstrap.ldif


# Reiniciar el contenedor
docker stop ldap
docker start ldap
