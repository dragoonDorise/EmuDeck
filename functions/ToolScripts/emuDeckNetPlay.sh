#!/bin/bash

# netplay -true false
# netplayIP
# netplayHost - true false
# netplayType - local inet
# netplayCMD - local inet

#Searchs for a device with the netplay port open
netplaySetIP(){
	localIP=$(ip addr show $(ip route | awk '/default/ { print $5 }') | grep "inet" | head -n 1 | awk '/inet/ {print $2}' | cut -d'/' -f1)
	segment=$(echo $localIP | awk -F '.' '{print $1"."$2"."$3}')
	subnet="$segment".
	port=55435
	for i in {2..255}; do
		 {
			ip="$subnet$i"
			if (echo > /dev/tcp/$ip/$port) >/dev/null 2>&1; then
				setSetting netplayCMD "'-C $ip'"
				exit
			fi
		 } &
	done

}