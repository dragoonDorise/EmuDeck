#!/bin/bash

netplaySetIP(){
	localIP=$(ip addr show $(ip route | awk '/default/ { print $5 }') | grep "inet" | head -n 1 | awk '/inet/ {print $2}' | cut -d'/' -f1)
	segment=$(echo $localIP | awk -F '.' '{print $1"."$2"."$3}')
	subnet="$segment".
	port=55435
	timeout_seconds=1
	setSetting netplayIP "false"

	for i in {2..254}; do
		{
			ip="$subnet$i"
			if nc -z -w $timeout_seconds $ip $port >/dev/null 2>&1; then
				  setSetting netplayIP $ip
				exit
			fi
		} &
	done
}