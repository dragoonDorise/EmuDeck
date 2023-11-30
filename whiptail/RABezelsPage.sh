#!/bin/bash

if [ $deviceAR == 169 ] || [ $deviceAR == 53 ]; then
	while true; do
		question=$(whiptail --title "Game Bezels" \
   	--radiolist "You can use our preconfigured bezels to hide the vertical black vars on 8bit and 16bits games" 10 80 4 \
		"YES" "Enable preconfigured bezels to hide black vars on Retro games" ON \
		"NO" "NO" OFF \
   	3>&1 1<&2 2>&3)
		case $question in
			[YES]* ) break;;
			[NO]* ) break;;
			* ) echo "Do you want bezels?";;
		esac
	done
	
	if [ $question == 'YES' ]; then
		setSetting RABezels true
	else
		setSetting RABezels false
	fi
fi