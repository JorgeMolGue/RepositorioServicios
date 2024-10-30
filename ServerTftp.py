import os
import tftpy

class Tftp:
    def __init__(self, ip, port, directorio):
        self.ip = ip
        self.port = port
        self.directorio = directorio

    def asignar_directorio(self):
        # Verificar si el directorio existe
        if not os.path.exists(self.directorio):
            print(f"El directorio {self.directorio} no existe. Creándolo...")
            os.makedirs(self.directorio)  

        self.server = tftpy.TftpServer(self.directorio)

    def escuchar(self):
        print(f"Servidor TFTP escuchando en {self.ip}:{self.port}")
        self.server.listen(self.ip, self.port)

if __name__ == "__main__":
    myFTP = Tftp("0.0.0.0", 69, r"C:\Users\jorge\tftp\copias")  
    myFTP.asignar_directorio()  
    myFTP.escuchar()  
    print('Servidor TFTP corriendo...')
