#!/bin/bash

# Función para obtener información WHOIS del dominio
obtener_info_whois() {
    whois "$1"
}

# Función para obtener información DNS
obtener_info_dns() {
    nslookup "$1"
}

# Función para realizar un ping al dominio
obtener_info_ping() {
    ping -c 4 "$1"
}

# Función para realizar un traceroute al dominio
obtener_info_traceroute() {
    traceroute "$1"
}

obtener_info_nmap() {
    nmap "$1"
}

# Función para guardar información en un archivo
guardar_info_archivo() {
    echo "$2" >> "$1"
}

echo "Ingrese el dominio o IP a analizar:"
read dominio

archivo_salida="info_relevante.txt"

# Limpiar archivo de salida
> "$archivo_salida"

# Obtener información WHOIS y guardarla en el archivo de salida
info_whois=$(obtener_info_whois "$dominio")
guardar_info_archivo "$archivo_salida" "=== Información WHOIS ==="
guardar_info_archivo "$archivo_salida" "$info_whois"

# Obtener información DNS y guardarla en el archivo de salida
info_dns=$(obtener_info_dns "$dominio")
guardar_info_archivo "$archivo_salida" "=== Información DNS ==="
guardar_info_archivo "$archivo_salida" "$info_dns"

# Realizar un ping y guardar la información en el archivo de salida
info_ping=$(obtener_info_ping "$dominio")
guardar_info_archivo "$archivo_salida" "=== Resultado del Ping ==="
guardar_info_archivo "$archivo_salida" "$info_ping"

# Realizar traceroute y guardar la información en el archivo de salida
info_traceroute=$(obtener_info_traceroute "$dominio")
guardar_info_archivo "$archivo_salida" "=== Resultado del Traceroute ==="
guardar_info_archivo "$archivo_salida" "$info_traceroute"

# Escanear puertos utilizando Nmap y guardar la información en el archivo de salida
info_nmap=$(obtener_info_nmap "$dominio")
guardar_info_archivo "$archivo_salida" "=== Resultado del Escaneo de Puertos con Nmap ==="
guardar_info_archivo "$archivo_salida" "$info_nmap"

echo "Se ha recopilado la información relevante en el archivo $archivo_salida."
