#!/bin/bash
while true; do
	question=$(whiptail --title "Choose your aspect ratio for your GameCube Games" \
   --radiolist "Choose your aspect ratio for your GameCube Games" 10 80 4 \
	"43" "4:3 Original TV Aspect Ratio" ON \
	"169" "16:9 Widescreen using WideScreen hacks" OFF \
   3>&1 1<&2 2>&3)
	case $question in
		[43]* ) break;;
		[169]* ) break;;
		* ) echo "Please select your AR for Dolphin.";;
	esac
done

if [ $question == 43 ]; then
	setSetting arDolphin 43
else
	setSetting arDolphin 169
fi