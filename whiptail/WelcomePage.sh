#!/bin/bash
while true; do
	question=$(whiptail --title "EmuDeck configuration mode" \
   --radiolist "Move using your DPAD and select your platforms with the Y button. Press the A button to select." 10 80 4 \
	"EASY" "This is a 100% automatic mode. Install & Play" OFF \
	"CUSTOM" "You will be able tu customize what to install" OFF \
   3>&1 1<&2 2>&3)
	case $question in
		[EASY]* ) break;;
		[CUSTOM]* ) break;;
		* ) echo "Please select your mode.";;
	esac
done

if [ $question == 'EASY' ]; then
	setSetting expert false
else
	setSetting expert true
fi