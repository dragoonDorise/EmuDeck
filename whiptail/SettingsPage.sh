#!/bin/bash
while true; do
	question=$(whiptail --title "Choose your Storage" \
   --radiolist "Where do you want to store your roms? " 10 80 4 \
	"INTERNAL" "We will create your rom folders on your Android's Internal Storage" OFF \
	"SDCARD" "If your device has a SDCARD " OFF \
   3>&1 1<&2 2>&3)
	case $question in
		[EASY]* ) break;;
		[CUSTOM]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
done

if [ $question == 'EASY' ]; then
	setSetting expert false
else
	setSetting expert true
fi