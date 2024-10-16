from netmiko import ConnectHandler

class Router():
    def __init__(self, device_type, ip, username, password):
        self.device_type = device_type
        self.ip = ip
        self.username = username
        self.password = password
        self.conexion = None  # Para almacenar la conexión

    def establecer_conexion(self):
        # Crear un diccionario de conexión para Netmiko
        router_config = {
            "device_type": self.device_type,
            "ip": self.ip,
            "username": self.username,
            "password": self.password
        }
        try:
            # Intentar establecer la conexión
            self.conexion = ConnectHandler(**router_config)
            print(f"Conexión establecida con {self.ip}.")
        except Exception as e:
            # Capturar errores si la conexión falla
            print(f"Error al conectar con {self.ip}: {e}")
            self.conexion = None

    def comando(self, comando):
        if self.conexion:
            try:
                # Ejecutar el comando y obtener la salida
                self.salida = self.conexion.send_command(comando)
                print(f"Salida del comando '{comando}' en {self.ip}:")
                print(self.salida)
            except Exception as e:
                print(f"Error al ejecutar el comando en {self.ip}: {e}")
        else:
            print(f"No se puede ejecutar el comando. No hay conexión con {self.ip}.")

    def cerrar_conexion(self):
        if self.conexion:
            self.conexion.disconnect()
            print(f"Conexión con {self.ip} cerrada.")
        else:
            print(f"No hay conexión activa para cerrar en {self.ip}.")

# Uso de la clase
if __name__ == "__main__":
    # Instancias de diferentes dispositivos
    cisco = Router("cisco_ios", "192.168.180.8", "admin", "admin123")
    mikrotik = Router("mikrotik_routeros", "192.168.180.9", "admin", "admin")
    bird2 = Router("linux", "192.168.180.10", "gns3", "gns3")
    olivia = Router("juniper_junos", "192.168.180.11", "root", "jorge123")
    # Establecer conexiones
    cisco.establecer_conexion()
    mikrotik.establecer_conexion()
    bird2.establecer_conexion()
    olivia.establecer_conexion()

    # Ejecutar comandos
    cisco.comando("show ip interface brief")
    mikrotik.comando("ip/address/print")
    bird2.comando("ip addr show")
    olivia.comando("edit")
    olivia.comando("show")
    # Cerrar conexiones
    cisco.cerrar_conexion()
    mikrotik.cerrar_conexion()
    bird2.cerrar_conexion()
    olivia.cerrar_conexion()
