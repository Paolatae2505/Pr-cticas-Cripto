#!/bin/bash

echo "-----------------------------------"
echo "Ingrese el dominio o IP a analizar:"
echo "-----------------------------------"
read dominio

archivo_salida="info_relevante.txt"

# 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

# Limpiar archivo de salida
> "$archivo_salida"

# Obtener información WHOIS y guardarla en el archivo de salida
echo "=== Información WHOIS ===" >> "$archivo_salida"
whois "$dominio" | grep -E 'Domain Name:|Creation Date:|Updated Date:|Registry Expiry Date:|Registrant Name:|Registrant Organization:|Registrant Street:|Registrant City:|Registrant State/Province:|Registrant Postal Code:|Registrant Country:|Registrant Phone:|Registrant Email:' >> "$archivo_salida"

# Obtener información DNS y guardarla en el archivo de salida
echo "=== Información DNS ===" >> "$archivo_salida"
nslookup "$dominio" | grep -E 'Name:|Address:' >> "$archivo_salida"

# Realizar un ping y guardar la información en el archivo de salida
echo "=== Resultado del Ping ===" >> "$archivo_salida"
ping -c 4 "$dominio" >> "$archivo_salida"

# Realizar traceroute y guardar la información en el archivo de salida
echo "=== Resultado del Traceroute ===" >> "$archivo_salida"
traceroute "$dominio" >> "$archivo_salida"

# Escanear puertos utilizando Nmap y guardar la información en el archivo de salida
echo "=== Resultado del Escaneo de Puertos con Nmap ===" >> "$archivo_salida"
nmap -Pn -p- --open -T4 "$dominio" >> "$archivo_salida"

echo "Se ha recopilado la información relevante en el archivo $archivo_salida."