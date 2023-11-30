#!/bin/bash
while true; do
	question=$(whiptail --title "Configure LCD Shader simulates the old LCD Matrix screens of handheld systems" \
   --radiolist "Enabling a LCD Shader simulates the old LCD Matrix screens of handheld systems" 10 80 4 \
	"ON" "Enable" ON \
	"OFF" "Disable" OFF \
   3>&1 1<&2 2>&3)
	case $question in
		[ON]* ) break;;
		[OFF]* ) break;;
		* ) echo "Enable LCD Shaders?";;
	esac
done

if [ $question == 'ON' ]; then
	setSetting RAHandHeldShader true
else
	setSetting RAHandHeldShader false
fi