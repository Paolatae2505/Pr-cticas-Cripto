#!/bin/bash

# Solicitar al usuario que ingrese el nombre del dominio o la IP
echo "-------------------------------------------------"
read -p "Ingresa el nombre de dominio / IP's: " domain



# Verificar si la entrada es una dirección IP
if [[ "$domain" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Haz proporcionado una dirección IP"
    
    exec > >(tee pentesting_$domain.txt)

    whois_info=$(whois $domain)
    # Imprimir información deseada
    echo "----------------------------------------------"
    echo "-------- INFORMACIÓN DEL DOMINIO -------------"
    echo "----------------------------------------------"

    echo "$whois_info" | grep -E 'owner|country|address' | sed -e 's/owner/Nombre Org/' -e 's/country/País/' -e 's/address/Dirección/' 

    # Imprimir información deseada
    echo "----------------------------------------------"
    echo "-------- INFORMACIÓN DE CONTACTO -------------"
    echo "----------------------------------------------"

    echo "$whois_info" | grep -E 'person|e-mail|phone' | sed -e 's/Person/Nombre del personal/' -e 's/e-mail/Correo electrónico/' -e 's/Phone/Teléfono/'


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
    echo "------ INFORMACIÓN DE LA IP PÚBLICA ----------"
    echo "----------------------------------------------"

    echo "IP Pública: $domain"
    ip_segment=$(echo "$domain" | cut -d'.' -f1-3 | cut -d':' -f1-4)
    echo "Segmentos de la IP: $ip_segment" 
    
    echo "----------------------------------------------"
    echo "----------- REGISTROS REVERSOS ---------------"
    echo "----------------------------------------------"
    
    ptr=$(nslookup -type=PTR $domain)
    ptr=$(echo "$ptr" | awk '/name =/ {print $NF}')
    echo "Nombre de dominio: $ptr"
    
    echo "----------------------------------------------"
    echo "--------- RUTA Y SALTOS AL DOMINIO -----------"
    echo "----------------------------------------------"
    
    ruta=$(traceroute $domain)
    echo "$ruta"
    
    echo "----------------------------------------------"
    echo "--------------- DNS ENUMERADOS ---------------"
    echo "----------------------------------------------"
    
    dns=$(dnsmap $domain)
    echo="$dns"
    
    echo "----------------------------------------------"
    echo "-------- PUERTOS, ESTADOS Y SERVICIO ---------"
    echo "----------------------------------------------"
    
    puertos=$(nmap $domain)
    if [[ $puertos == *"Failed"* || $puertos == *"WARNING"* ]]; then
    	echo "Fallo al resolver el nombre de dominio."
    else
    	puertos=$(echo "$puertos" | awk '/^PORT/ {flag=1} flag {print}' | sed '/^[[:space:]]*$/d' | grep -v '^Nmap')
    	echo "$puertos"
    fi
    
else

    echo "Haz proporcionado un Dominio"
    
    exec > >(tee pentesting_$domain.txt)
    
    # Obtener información WHOIS
    whois_info=$(whois $domain)

    domain_extension="${domain##*.}"

    # Obtener la IP pública y sus segmentos usando nslookup
    ip_info=$(nslookup $domain)

    # Extraer la IP pública y sus segmentos de la salida de nslookup
    ip_address=$(echo "$ip_info" | awk '/^Address: / { print $2 }')
    ip_segment=$(echo "$ip_address" | cut -d'.' -f1-3)

    # Obtener el registro de disponibilidad
    availability=$(whois $domain | grep -i "domain status" | awk '{print $3}')

   echo "----------------------------------------------"
   echo "-------- INFORMACIÓN DEL DOMINIO -------------"
   echo "----------------------------------------------"

   # Utilizamos sed para eliminar espacios en blanco adicionales y dar formato a la salida
   echo "$whois_info" | grep -E 'Domain Name|Created On|Creation Date|Last Updated On|Updated Date|Expiration Date|Registry Expiry Date' | sed -e 's/^\s*//;s/\s\s*/ /g' | sed -e 's/Domain Name/Nombre del Dominio/' -e 's/Created On\|Creation Date/Fecha de Creación/' -e 's/Last Updated On\|Updated Date/Última Actualización/' -e 's/Expiration Date\|Registry Expiry Date/Fecha de Vencimiento/'

    
    if [ "$domain_extension" = "com" ]; then


    	# Imprimir información deseada del registrante
    	echo "----------------------------------------------"
    	echo "-------- INFORMACIÓN DEL REGISTRANTE ---------"
    	echo "----------------------------------------------"
    	echo "$whois_info" | grep -E 'Registrant Organization:|Registrant Country:|Registrant State/Province:|Registrant City:|Registrant Street:|Registrant Postal Code:' | sed -e 's/Registrant Organization:/Nombre de la Organización/' -e 's/Registrant Country:/País/' -e 's/Registrant State\/Province:/Estado\/Provincia :/' -e 's/Registrant City:/Ciudad :/' -e 's/Registrant Street:/Dirección :/' -e 's/Registrant Postal Code:/Código Postal :/'

    	# Imprimir información deseada del contacto administrativo
    	echo "----------------------------------------------"
    	echo "-------- INFORMACIÓN DEL PERSONAL ------------"
    	echo "----------------------------------------------"
    	echo "$whois_info" | grep -E 'Registrant Name:|Registrant Email:|Registrant Phone:' | sed -e 's/Registrant Name:/Nombre :/' -e 's/Registrant Email:/Correo electrónico :/' -e 's/Registrant Phone:/Teléfono :/'
    else
    	echo "----------------------------------------------"
    	echo "-------- INFORMACIÓN DEL REGISTRANTE ---------"
    	echo "----------------------------------------------"
    	echo "$whois_info" | grep -A3 'Registrant:' | grep -E 'Name:|City:|State:|Country:|Country Name:' | sed -e 's/Name/Nombre Org :/' -e 's/City/Ciudad :/' -e 's/State/Estado :/' -e 's/Country/País :/' -e 's/Country Name/Nombre del País :/'

    	echo "----------------------------------------------"
    	echo "-------- INFORMACIÓN DEL PERSONAL ------------"
    	echo "----------------------------------------------"

    	echo "Contacto Administrativo :"
    	echo "$whois_info" | grep -A3 'Administrative Contact:' | grep -E 'Name:|City:|State:|Country:|Country Name:' | sed -e 's/Name/Nombre/' -e 's/City/Ciudad/' -e 's/State/Estado/' -e 's/Country/País/' -e 's/Country Name/Nombre del País/'

    	echo "Contacto Técnico :"
    	echo "$whois_info" | grep -A3 'Technical Contact:' | grep -E 'Name:|City:|State:|Country:|Country Name:' | sed -e 's/Name/Nombre/' -e 's/City/Ciudad/' -e 's/State/Estado/' -e 's/Country/País/' -e 's/Country Name/Nombre del País/'

    	echo "Contacto de facturación :"
    	echo "$whois_info" | grep -A3 'Billing Contact:' | grep -E 'Name:|City:|State:|Country:|Country Name:' | sed -e 's/Name/Nombre/' -e 's/City/Ciudad/' -e 's/State/Estado/' -e 's/Country/País/' -e 's/Country Name/Nombre del País/'
    fi
   

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
    echo "------ INFORMACIÓN DE LA IP PÚBLICA ----------"
    echo "----------------------------------------------"

    echo "IP Pública: $ip_address"
    echo "Segmentos de la IP: $ip_segment"
    
    echo "----------------------------------------------"
    echo "--------- REGISTROS IPv4 e IPv6 --------------"
    echo "----------------------------------------------"

    ipv4=$(nslookup -type=A $domain)
    ipv4=$(echo "$ipv4" | awk '/^Address: / { print $2 }')
    echo "IPv4: $ipv4"
    
    ipv6=$(nslookup -type=AAAA $domain)
    ipv6=$(echo "$ipv6" | awk '/^Address: / { print $2 }')
    echo "IPv6: $ipv6"
    
    echo "----------------------------------------------"
    echo "--------- RUTA Y SALTOS AL DOMINIO -----------"
    echo "----------------------------------------------"
    
    ruta=$(traceroute $domain)
    
    if [[ $ruta == *"Name or service not known"* || $ruta == *"Cannot handle"* ]]; then
    	echo "No se pudo manejar el dominio."
    else
    	echo "$ruta"
    fi
    
    echo "----------------------------------------------"
    echo "--------------- DNS ENUMERADOS ---------------"
    echo "----------------------------------------------"
    
    dns=$(dnsmap $domain)
    dns=$(echo "$dns" | sed '1d' | sed '/^[[:space:]]*$/d' | grep -v '^\[+\]')
    echo "$dns"
    
    echo "----------------------------------------------"
    echo "-------- PUERTOS, ESTADOS Y SERVICIO ---------"
    echo "----------------------------------------------"
    
    puertos=$(nmap $domain)
    if [[ $puertos == *"Failed"* || $puertos == *"WARNING"* ]]; then
    	echo "Fallo al resolver el nombre de dominio."
    else
    	puertos=$(echo "$puertos" | awk '/^PORT/ {flag=1} flag {print}' | sed '/^[[:space:]]*$/d' | grep -v '^Nmap')
    	echo "$puertos"
    fi
 
fi
