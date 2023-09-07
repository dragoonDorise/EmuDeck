#!/bin/bash
clear
echo -e "EmuDeck for ${GREEN}Android${NONE} ${RED}BETA${NONE}"
echo -e  "${BOLD}You must hide the virtual keyboard to continue so you can read all the instructions${NONE}"
echo -e  "If your controller is not being recognized you might need to connect a Keyboard."
echo -e  "Press the ${RED}A button${NONE} when ready"
read clear
clear
echo -e  "${BOLD}We will ask you several questions where you will need to pick a choice, you can choose using these controls${NONE}"
echo -e  "DPAD = Move around options"
echo -e  "${GREEN}Y button${NONE} = Select option"
echo -e  "${RED}A button${NONE} = Accept"
echo -e  "Press the ${RED}A button${NONE} to start"
read clear
clear
  
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