#!/bin/bash
while true; do
	question=$(whiptail --title "Choose your aspect ratio for your Classic Sega Systems" \
   --radiolist "Choose your aspect ratio for your Classic Sega Systems" 10 80 4 \
	"43" "4:3 Original TV Aspect Ratio" ON \
	"32" "3:2 Less black bars, slight distortion " OFF \
   3>&1 1<&2 2>&3)
	case $question in
		[43]* ) break;;
		[32]* ) break;;
		* ) echo "Please select your AR for Sega.";;
	esac
done

if [ $question == 43 ]; then
	setSetting arSega 43
else
	setSetting arSega 32
fi