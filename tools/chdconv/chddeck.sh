#!/bin/bash
# shellcheck source=/home/deck/emudeck/settings.sh
. ~/emudeck/settings.sh

if [[ "$EMUDECKGIT" == "" ]]; then
    EMUDECKGIT="$HOME/.config/EmuDeck/backend"
fi

#whitelist
declare -a chdfolderWhiteList=("dreamcast" "psx" "segacd" "3do" "saturn" "tg-cd" "pcenginecd" "pcfx" "amigacd32" "neogeocd" "megacd" "ps2")
declare -a rvzfolderWhiteList=("gamecube" "wii" "primehacks")
declare -a csofolderWhiteList=("psp")
declare -a searchFolderList

#executables
chdPath="$EMUDECKGIT/tools/chdconv"
chmod +x "$chdPath/chdman5"
chmod +x "$chdPath/ciso"
export PATH="${chdPath}/:$PATH"
flatpaktool=$(flatpak list --columns=application | grep -E dolphin\|primehack | head -1)
dolphintool="flatpak run --command=dolphin-tool $flatpaktool"

#initialize log
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
mkdir -p "$HOME/emudeck/logs/compression"
LOGFILE="$HOME/emudeck/logs/compression/chdman-$TIMESTAMP.log"
exec > >(tee "${LOGFILE}") 2>&1

#compression functions
compressCHD() {
	local file=$1
	local fileType="${file##*.}"
	local CUEDIR=""
	local successful=''
	CUEDIR="$(dirname "${file}")"
	echo "Compressing ${file%.*}.chd"
	chdman5 createcd -i "$file" -o "${file%.*}.chd" && successful="true"
	if [[ $successful == "true" ]]; then
		echo "successfully created ${file%.*}.chd"
		if [[ ! ("$fileType" == 'iso' || "$fileType" == 'ISO') ]]; then
			find "${CUEDIR}" -maxdepth 1 -type f | while read -r b; do
				fileName="$(basename "${b}")"
				found=$(grep "${fileName}" "${file}")
				if [[ ! $found = '' ]]; then
					echo "Deleting ${b}"
					rm "${b}"
				fi
			done
		fi
		rm -f "${file}"
	else
		echo "Conversion of ${file} failed."
		rm -f "${file%.*}.chd"
	fi
}

compressRVZ() {
	local file=$1
	local successful=''
	${dolphintool} convert -f rvz -b 131072 -c zstd -l 5 -i "$file" -o "${file%.*}.rvz" && successful="true"
	if [[ $successful == "true" ]]; then
		echo "$file succesfully converted to ${file%.*}.rvz"
		rm -f "$file"
	else
		echo "error converting $file"
		rm -f "${file%.*}.rvz"
	fi
}

compressCSO() {
	local file=$1
	local successful=''
	ciso 9 "$file" "${file%.*}.cso" && successful="true"
	if [[ $successful == "true" ]]; then
		echo "$file succesfully converted to ${file%.*}.cso"
		rm -f "$file"
	else
		echo "error converting $file"
		rm -f "${file%.*}.cso"
	fi

}

#main
text="$(printf "<b>Hi</b>\nWelcome to EmuDeck's Game Compression script!\n\nPlease be very careful and make sure you have backups of roms.\n\nThis script will scan the roms folder you choose and will compress the files it can to the best available format.\n\n<b>This action will delete the old files if the compression succeeds</b>")"
selection=$(zenity --question \
	--title="EmuDeck" \
	--width=250 \
	--ok-label="Bulk Compress" \
	--extra-button="Pick a file" \
	--cancel-label="Exit" \
	--text="${text}" 2>/dev/null && echo "bulk")

if [ "$selection" == "bulk" ]; then

	#paths update via sed in main script
	#romsPath="/run/media/mmcblk0p1/Emulation/roms" #use path from settings
	#toolsPath="/run/media/mmcblk0p1/Emulation/tools"

	#ask user if they want to pick manually or run a search for eligible files. Manual will need to ask the user to pick a file, and then it will need to ask the type to convert to. (chd, rvz, cso)

	echo "Checking ${romsPath:?} for files eligible for conversion."

	#find file types we support within whitelist of folders
	for romfolder in "${chdfolderWhiteList[@]}"; do
		echo "Checking ${romsPath}/${romfolder}/"
		mapfile -t files < <(find "${romsPath}/${romfolder}/" -type f -iname "*.gdi" -o -type f -iname "*.cue" -o -type f -iname "*.iso")
		if [ ${#files[@]} -gt 0 ]; then
			echo "found in $romfolder"
			searchFolderList+=("$romfolder")
		fi
	done
	if [[ -n "$flatpaktool" ]]; then #ensure tools are in place
		for romfolder in "${rvzfolderWhiteList[@]}"; do
			echo "Checking ${romsPath}/${romfolder}/"
			mapfile -t files < <(find "${romsPath}/${romfolder}/" -type f -iname "*.gcm" -o -type f -iname "*.iso")
			if [ ${#files[@]} -gt 0 ]; then
				echo "found in $romfolder"
				searchFolderList+=("$romfolder")
			fi
		done
	fi
	for romfolder in "${csofolderWhiteList[@]}"; do
		echo "Checking ${romsPath}/${romfolder}/"
		mapfile -t files < <(find "${romsPath}/${romfolder}/" -type f -iname "*.iso")
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
	folderstoconvert=$(
		zenity --list \
			--title="EmuDeck" \
			--height="$height" \
			--width=250 \
			--ok-label="OK" \
			--cancel-label="Exit" \
			--text="${text}" \
			--checklist \
			--column="" \
			--column=${selectColumnStr}
	) #goddamnit shellcheck broke this. array! do not quote.
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

			find "$romsPath/$romfolder" -type f -iname "*.gdi" | while read -r f; do
				echo "Converting: $f"
				compressCHD "$f"
			done
			find "$romsPath/$romfolder" -type f -iname "*.cue" | while read -r f; do
				if [ "$romfolder" != "dreamcast" ]; then #disallow dreamcast for cue / bin
					echo "Converting: $f"
					compressCHD "$f"
				else
					echo "Sorry - at this time dreamcast games cannot be cue / bin for chd compression"
					echo "Skipping $f"
				fi
			done
			find "$romsPath/$romfolder" -type f -iname "*.iso" | while read -r f; do
				echo "Converting: $f"
				compressCHD "$f"
			done
		fi
	done

	#rvz

	for romfolder in "${romfolders[@]}"; do
		if [[ " ${rvzfolderWhiteList[*]} " =~ " ${romfolder} " ]]; then
			find "$romsPath/$romfolder" -type f -iname "*.gcm" -o -type f -iname "*.iso" | while read -r f; do
				echo "Converting: $f"
				compressRVZ "$f"
			done
		fi
	done

	#cso

	for romfolder in "${romfolders[@]}"; do
		if [[ " ${csofolderWhiteList[*]} " =~ " ${romfolder} " ]]; then
			find "$romsPath/$romfolder" -type f -iname "*.iso" | while read -r f; do
				echo "Converting: $f"
				compressCSO "$f"
			done
		fi
	done

elif [ "$selection" == "Pick a file" ]; then

	#/bin/bash
	f=$(zenity --file-selection --file-filter='Discs (cue,gdi,iso,gcm) | *.cue *.gdi *.iso *.gcm' --file-filter='All files | *' 2>/dev/null)
	ext=$(echo "${f##*.}" | awk '{print tolower($0)}')
	case $ext in

	gcm)
		echo gcm
		;;

	iso)
		echo iso
		;;

	gdi)
		echo gdi
		;;

	cue)
		echo cue
		;;
	esac

	compressCHD "$f"
else
	exit
fi

echo "All files compressed!"

if [ "$uiMode" != 'zenity' ]; then
	text="$(printf " <b>All files have been compressed!</b>")"
	zenity --info \
		--title="EmuDeck" \
		--width="450" \
		--text="${text}" 2>/dev/null
fi

if [ "$uiMode" == 'zenity' ]; then

	text="$(printf "<b>Done!</b>\n\n If you use Steam ROM Manager to catalog your games you will need to open it now to update your games")"
	zenity --question \
		--title="EmuDeck" \
		--width=450 \
		--ok-label="Open Steam ROM Manager" \
		--cancel-label="Exit" \
		--text="${text}" 2>/dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		echo "user launched SRM"
		"${toolsPath}/Steam ROM Manager.AppImage"
		exit
	else
		exit
	fi

fi
