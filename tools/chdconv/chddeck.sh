#!/bin/bash
chmod +x ~/emudeck/chdconv/chdman5
export PATH="$HOME/emudeck/chdconv/:$PATH"
romsPath=~/Emulation/roms/

text="`printf "<b>Hi!</b>\nWelcome to EmuDeck's CHD conversion script!\n\nThis script will scan all your roms folders and convert all your .cue/.bin and .gdi files to the superior CHD format.\n\n<b>This action will delete the old files if the conversion to chd succeds</b>"`"
#Nova fix'
zenity --question \
		 --title="EmuDeck" \
		 --width=250 \
		 --ok-label="Ok, let's start" \
		 --cancel-label="Exit" \
		 --text="${text}" &>> /dev/null
ans=$?
if [ $ans -eq 0 ]; then
	text="Do you have your files on your SD Card or on your Internal Storage?"
	zenity --question \
			 --title="EmuDeck" \
			 --width=250 \
			 --ok-label="SD Card" \
			 --cancel-label="Internal Storage" \
			 --text="${text}" &>> /dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		echo "Storage: SD" &>> ~/emudeck/emudeck.log
		destination="SD"
		echo "" > ~/emudeck/.SD
	else
		echo "Storage: INTERAL" &>> ~/emudeck/emudeck.log
		destination="INTERNAL"
	fi
	
	if [ $destination == "SD" ]; then
		romsPath="/run/media/mmcblk0p1/Emulation/roms/"
	fi
	
	find "$romsPath" -not -path "$romsPath/psp" -type f -name "*.cue" | while read f; do chdman5 createcd -i "$f" -o "${f%.*}.chd" && rm -rf "${f%.*}.cue" && rm -rf "${f%.*}.bin"; done;
	find "$romsPath" -not -path "$romsPath/psp" -type f -name "*.gdi" | while read f; do chdman5 createcd -i "$f" -o "${f%.*}.chd" && rm -rf "${f%.*}.cue" && rm -rf "${f%.*}.bin"; done;
	find "$romsPath" -not -path "$romsPath/psp" -type f -name "*.iso" | while read f; do chdman5 createcd -i "$f" -o "${f%.*}.chd" && rm -rf "${f%.*}.cue" && rm -rf "${f%.*}.bin"; done;
	
else
	exit
fi

text="`printf "<b>Done!</b>\n\n If you use Steam Rom Manager to catalog your games you will need to open it now to update your games"`"
zenity --question \
		 --title="EmuDeck" \
		 --width=450 \
		 --ok-label="Open Steam Rom Manager" \
		 --cancel-label="Exit" \
		 --text="${text}" &>> /dev/null
ans=$?
if [ $ans -eq 0 ]; then
	cd ~/Desktop/
	./Steam-ROM-Manager.AppImage
	exit
else
	exit
	echo -e "Exit" &>> /dev/null
fi

sleep 99999