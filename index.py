from pysnmp.hlapi import getCmd, SnmpEngine, CommunityData, UdpTransportTarget, ContextData, ObjectType, ObjectIdentity

# Lista de routers con sus IPs y comunidades
routers = [
    {'ip': '192.168.180.8', 'comunidad': 'router_cisco'},
    {'ip': '192.168.180.9', 'comunidad': 'router_MK'},
    {'ip': '192.168.180.10', 'comunidad': 'router_BI'},
    {'ip': '192.168.180.11', 'comunidad': 'router_OL'}
]

# Lista de OIDs que deseas consultar
oids = [
    ObjectType(ObjectIdentity('1.3.6.1.2.1.1.1.0')),  # sysDescr
    ObjectType(ObjectIdentity('1.3.6.1.2.1.1.3.0')),  # sysUpTime
    ObjectType(ObjectIdentity('1.3.6.1.2.1.2.1.0')),  # ifNumber
    ObjectType(ObjectIdentity('1.3.6.1.4.1.9.2.1.58.0')),  # cpmCPUTotal5min
    ObjectType(ObjectIdentity('1.3.6.1.4.1.9.9.48.1.1.1.5.1'))  # ciscoMemoryPoolUsed
]

# Iterar sobre los routers
for router in routers:
    print(f"Consultando router en {router['ip']} con la comunidad {router['comunidad']}")

    # Crear el iterador para la solicitud SNMP
    iterator = getCmd(
        SnmpEngine(),  # Crear un motor SNMP
        CommunityData(router['comunidad']),  # Nombre de la comunidad específico del router
        UdpTransportTarget((router['ip'], 161)),  # Dirección IP del router y puerto 161 (SNMP)
        ContextData(),  # Contexto vacío para SNMPv2c
        *oids  # Desempaquetar la lista de OIDs
    )

    # Obtener la respuesta de la solicitud SNMP
    errorIndication, errorStatus, errorIndex, varBinds = next(iterator)

    # Manejo de errores y mostrar resultados
    if errorIndication:
        print(f"Error de conexión o solicitud en {router['ip']}: {errorIndication}")

    elif errorStatus:
        print(f"Error SNMP en {router['ip']}: {errorStatus.prettyPrint()} en {errorIndex and varBinds[int(errorIndex) - 1][0] or '?'}")

    else:
        print(f"Resultados para router en {router['ip']}:")
        for varBind in varBinds:
            print(' = '.join([x.prettyPrint() for x in varBind]))
        print("-" * 40)  # Separador entre routers
