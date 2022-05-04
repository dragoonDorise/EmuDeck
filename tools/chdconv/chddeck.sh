#!/bin/bash

text="`printf "<b>Hi!</b>\nWelcome to EmuDeck's CHD conversion script!\n\nThis script will scan the roms folder you choose and convert all your .cue/.bin and .gdi files to the superior CHD format.\n\n<b>This action will delete the old files if the conversion to chd succeeds</b>"`"
#Nova fix'
zenity --question \
		 --title="EmuDeck" \
		 --width=250 \
		 --ok-label="Ok, let's start" \
		 --cancel-label="Exit" \
		 --text="${text}" &>> /dev/null
ans=$?
if [ $ans -eq 0 ]; then
	#paths update via sed in main script
	romsPath="/run/media/mmcblk0p1/Emulation/roms/"
	chdPath="/run/media/mmcblk0p1/Emulation/tools/chdconv/"

	#whitelist
	declare -a folderWhiteList=("dreamcast" "psx" "segacd" "3d0" "saturn" "tg-cd" "pcenginecd" "pcfx" "amigacd32" "neogeocd" "megacd")
	declare -a searchFolderList

	export PATH="${chdPath}/:$PATH"

	#find file types we support within whitelist of folders
	for romfolder in ${folderWhiteList[@]}; do
		echo "Checking $romsPath""$romfolder"
		files=(`find "$romsPath""$romfolder" -type f -iname "*.gdi" -o -type f -iname "*.cue" -o -type f -iname "*.iso"`)
		if [ ${#files[@]} -gt 0 ]; then 
			echo "found in $romfolder"
			searchFolderList+=("$romfolder")
		fi
	done
	numFolders=${#searchFolderList[@]}
	declare -i height=$numFolders*100
	selectColumnStr="RomFolder " 
	for (( i=1; i<=$numFolders; i++ )); do selectColumnStr+="$i ${searchFolderList[$i-1]} " ; done
	text="`printf "What folders do you want to convert?"`"
	folderstoconvert=$(zenity --list \
				--title="EmuDeck" \
				--height=$height \
				--width=250 \
				--ok-label="OK" \
				--cancel-label="Exit" \
				--text="${text}" \
				--checklist \
				--column="" \
				--column=${selectColumnStr})
	#folderstoconvert=(`echo $folderstoconvert | sed 's/|/ /g'`)
	IFS="|"
	IFS=', ' read -r -a romfolders <<< "$folderstoconvert"
	for romfolder in ${romfolders[@]}; do
		find "$romsPath$romfolder" -type f -iname "*.cue" | while read f; do chdman5 createcd -i "$f" -o "${f%.*}.chd" && rm -rf "$f" && rm -rf "${f%.*}.bin" && rm -rf "${f%.*}.BIN"; done;
		find "$romsPath$romfolder" -type f -iname "*.gdi" | while read f; do chdman5 createcd -i "$f" -o "${f%.*}.chd" && rm -rf "$f"; done;
		find "$romsPath$romfolder" -type f -iname "*.iso" | while read f; do chdman5 createcd -i "$f" -o "${f%.*}.chd" && rm -rf "$f"; done;
	done
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
