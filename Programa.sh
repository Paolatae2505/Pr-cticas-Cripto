#!/bin/bash

# Solicitar al usuario que ingrese el nombre del dominio
read -p "Ingresa el nombre de dominio: " domain

# Obtener información WHOIS
whois_info=$(whois $domain)

# Obtener la IP pública y sus segmentos usando nslookup
ip_info=$(nslookup $domain)

# Extraer la IP pública y sus segmentos de la salida de nslookup
ip_address=$(echo "$ip_info" | awk '/^Address: / { print $2 }')
ip_segment=$(echo "$ip_address" | cut -d'.' -f1-3)

# Obtener el registro de disponibilidad
availability=$(whois $domain | grep -i "domain status" | awk '{print $3}')

# Imprimir información deseada
echo "----------------------------------------------"
echo "-------- INFORMACIÓN DEL DOMINIO -------------"
echo "----------------------------------------------"

echo "$whois_info" | grep -E 'Domain Name|Created On|Last Updated On|Expiration Date'

echo "$whois_info" | grep -A3 'Registrant:' | grep -E 'Name:|City:|State:|Country:|Country Name:'

echo "----------------------------------------------"
echo "-------- INFORMACIÓN DEL PERSONAL ------------"
echo "----------------------------------------------"

echo "$whois_info" | grep -A3 'Administrative Contact:' | grep -E 'Name:|City:|State:|Country:|Country Name:'

echo "$whois_info" | grep -A3 'Technical Contact:' | grep -E 'Name:|City:|State:|Country:|Country Name:'

echo "$whois_info" | grep -A3 'Billing Contact:' | grep -E 'Name:|City:|State:|Country:|Country Name:'

echo "----------------------------------------------"
echo "--------- CONECTIVIDAD DE RED ----------------"
echo "----------------------------------------------"

# Realizar el ping al dominio
if ping_result=$(ping -c 4 $domain 2>&1); then
    echo "Conexión exitosa con $domain"
    latency=$(echo "$ping_result" | grep -oP 'round-trip.*?=' | awk '{print $4}')
    echo "Latencia: $latency ms"
else
    echo "No se pudo establecer conexión con $domain"
fi

echo "----------------------------------------------"
echo "------ INFORMACIÓN DE LA IP PÚBLICA -----------"
echo "----------------------------------------------"

echo "IP Pública: $ip_address"
echo "Segmentos de la IP: $ip_segment"


# Imprimir el registro de disponibilidad
echo "----------------------------------------------"
echo "---- REGISTRO DE DISPONIBILIDAD DEL DOMINIO ---"
echo "----------------------------------------------"
echo "Estado del dominio: $availability"

