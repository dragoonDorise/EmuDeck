#!/bin/bash
while true; do
	question=$(whiptail --title "Configure CRT Shader to give your classic systems a faux retro CRT vibe" \
   --radiolist "Enabling a CRT Shader gives your classic systems a faux retro CRT vibe" 10 80 4 \
	"ON" "Enable" ON \
	"OFF" "Disable" OFF \
   3>&1 1<&2 2>&3)
	case $question in
		[ON]* ) break;;
		[OFF]* ) break;;
		* ) echo "Please select if you want a shader.";;
	esac
done

if [ $question == 'ON' ]; then
	setSetting RAHandClassic2D true
else
	setSetting RAHandClassic2D false
fi