#!/bin/bash
while true; do
	question=$(whiptail --title "Choose your aspect ratio for your Dreamcast, Nintendo 64 and Playstation 1" \
   --radiolist "Choose your aspect ratio for your Dreamcast, Nintendo 64 and Playstation 1 Games" 10 80 4 \
	"43" "4:3 Original TV Aspect Ratio" ON \
	"169" "16:9 Widescreen using WideScreen hacks" OFF \
   3>&1 1<&2 2>&3)
	case $question in
		[43]* ) break;;
		[169]* ) break;;
		* ) echo "Please answer what AR you want for 3D.";;
	esac
done

if [ $question == 43 ]; then
	setSetting arClassic3D 43
else
	setSetting arClassic3D 169
fi