#!/bin/bash

text="$(printf "<b>Hi</b>\nWelcome to EmuDeck's CHD conversion script!\n\nThis is currently a <b>BETA</b> feature. Please be very careful and make sure you have backups of roms.\n\nThis script will scan the roms folder you choose and convert all your .cue/.bin and .gdi files to the superior CHD format.\n\n<b>This action will delete the old files if the conversion to chd succeeds</b>")"
#Nova fix'
zenity --question \
	--title="EmuDeck" \
	--width=250 \
	--ok-label="Ok, let's start" \
	--cancel-label="Exit" \
	--text="${text}" 2>/dev/null
ans=$?

if [ $ans -eq 0 ]; then
	#paths update via sed in main script
	romsPath="/run/media/mmcblk0p1/Emulation/roms/"
	toolsPath="/run/media/mmcblk0p1/Emulation/tools/"
	chdPath="${toolsPath}chdconv/"

	#initialize log
	TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
	LOGFILE="$chdPath/chdman-$TIMESTAMP.log"
	exec > >(tee "$LOGFILE") 2>&1

	#ask user if they want to pick manually or run a search for eligible files. Manual will need to ask the user to pick a file, and then it will need to ask the type to convert to. (chd, rvz, cso)

	echo "Checking $romsPath for files eligible for conversion."

	#whitelist
	declare -a chdfolderWhiteList=("dreamcast" "psx" "segacd" "3do" "saturn" "tg-cd" "pcenginecd" "pcfx" "amigacd32" "neogeocd" "megacd" "ps2")
	declare -a rvzfolderWhiteList=("gamecube" "wii")
	declare -a searchFolderList
	echo $chdfolderWhiteList
	export PATH="${chdPath}/:$PATH"

	#find file types we support within whitelist of folders
	for romfolder in "${chdfolderWhiteList[@]}"; do
		echo "Checking ${romsPath}${romfolder}/"
		files=($(find "${romsPath}${romfolder}/" -type f -iname "*.gdi" -o -type f -iname "*.cue" -o -type f -iname "*.iso"))
		if [ ${#files[@]} -gt 0 ]; then
			echo "found in $romfolder"
			searchFolderList+=("$romfolder")
		fi
	done

	for romfolder in "${rvzfolderWhiteList[@]}"; do
		echo "Checking ${romsPath}${romfolder}/"
		files=($(find "${romsPath}${romfolder}/" -type f -iname "*.gcm" -o -type f -iname "*.iso"))
		if [ ${#files[@]} -gt 0 ]; then
			echo "found in $romfolder"
			searchFolderList+=("$romfolder")
		fi
	done

	if ((${#searchFolderList[@]} == 0)); then
		echo "No eligible files found."
		text="$(printf "<b>No suitable roms were found for conversion.</b>\n\nPlease check if you have any cue / gdi / iso files for compatible systems.")"
		zenity --error \
			--title="EmuDeck" \
			--width=250 \
			--ok-label="Bye" \
			--text="${text}" 2>/dev/null
		exit
	fi

	declare -i height=(${#searchFolderList[@]}*100)
	selectColumnStr="RomFolder "
	for ((i = 1; i <= ${#searchFolderList[@]}; i++)); do selectColumnStr+="$i ${searchFolderList[$i - 1]} "; done
	text="$(printf "What folders do you want to convert?")"
	folderstoconvert=$(zenity --list \
		--title="EmuDeck" \
		--height="$height" \
		--width=250 \
		--ok-label="OK" \
		--cancel-label="Exit" \
		--text="$text" \
		--checklist \
		--column="" \
		--column="$selectColumnStr")
	echo "User selected $folderstoconvert" 2>/dev/null

	IFS="|" read -r -a romfolders <<<"$folderstoconvert"

	#query user about FileTypes? maybe they only want to convert bin/cue? Iso? Gdi?
	#check list here?

	# should be able to use grep / bash compare the files in the dir against the cue / gdi file to determine if it should be deleted.
	# something like after the processing of the cue / gdi succeeds, then do this
	# for file in folder           		#where file is a foreach variable and folder is some array of the files in the folder being processed.
	# if grep -q $file "$f"; then 		#where $f is the cue / gdi, and $file is a file in the folder.
	#	rm -rf $file
	# fi
	#

	#CHD
	for romfolder in "${romfolders[@]}"; do
		if [[ " ${chdfolderWhiteList[*]} " =~ " ${romfolder} " ]]; then
			find "$romsPath$romfolder" -type f -iname "*.cue" | while read f; do
				echo "Converting: $f"
				chdman5 createcd -i "$f" -o "${f%.*}.chd" && rm -rf "$f" && rm -rf "${f%.*}.bin"
			done
			find "$romsPath$romfolder" -type f -iname "*.gdi" | while read f; do
				echo "Converting: $f"
				chdman5 createcd -i "$f" -o "${f%.*}.chd" && rm -rf "$f"
			done #going to need work
			find "$romsPath$romfolder" -type f -iname "*.iso" | while read f; do
				echo "Converting: $f"
				chdman5 createcd -i "$f" -o "${f%.*}.chd" && rm -rf "$f"
			done
		fi
	done

	#rvz
	if [[ -f "${toolsPath}proton-launch.sh" && -f "${chdPath}DolphinTool.exe" ]]; then #ensure tools are in place
		for romfolder in "${romfolders[@]}"; do
			if [[ " ${rvzfolderWhiteList[*]} " =~ " ${romfolder} " ]]; then
				find "$romsPath$romfolder" -type f -iname "*.iso" | while read f; do
					echo "Converting: $f"
					${toolsPath}proton-launch.sh ${chdPath}DolphinTool.exe convert -f rvz -b 131072 -c zstd -l 5 -i "z:$f" -o "z:${f%.*}.rvz" && rm -rf "$f"
				done
				find "$romsPath$romfolder" -type f -iname "*.gcm" | while read f; do
					echo "Converting: $f"
					${toolsPath}proton-launch.sh ${chdPath}DolphinTool.exe convert -f rvz -b 131072 -c zstd -l 5 -i "z:$f" -o "z:${f%.*}.rvz" && rm -rf "$f"
				done
			fi
		done
	else
		echo "missing tools"
	fi
	#cso
	#

else
	exit
fi

text="$(printf "<b>Done!</b>\n\n If you use Steam Rom Manager to catalog your games you will need to open it now to update your games")"
zenity --question \
	--title="EmuDeck" \
	--width=450 \
	--ok-label="Open Steam Rom Manager" \
	--cancel-label="Exit" \
	--text="${text}" 2>/dev/null
ans=$?
if [ $ans -eq 0 ]; then
	cd "$HOME/Desktop/"
	echo "user launched SRM"
	./Steam-ROM-Manager.AppImage
	exit
else
	exit
	echo -e "Exit" &>>/dev/null
fi

sleep 99999
