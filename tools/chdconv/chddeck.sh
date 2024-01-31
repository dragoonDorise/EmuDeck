#!/bin/bash
# shellcheck source=/home/deck/emudeck/settings.sh
. ~/emudeck/settings.sh

if [[ "$EMUDECKGIT" == "" ]]; then
    EMUDECKGIT="$HOME/.config/EmuDeck/backend"
fi

#whitelist
chdfolderWhiteList=("dreamcast" "psx" "segacd" "3do" "saturn" "tg-cd" "pcenginecd" "pcfx" "amigacd32" "neogeocd" "megacd" "ps2")
rvzfolderWhiteList=("gamecube" "wii" "primehacks")
csofolderWhiteList=("psp")
n3dsfolderWhiteList=("3ds")
xboxfolderWhiteList=("xbox")
sevenZipfolderWhiteList=("atari2600" "famicom" "gamegear" 
"gb" "gbc" "gba" 
"genesis" "genesiswide" "lynx" 
"mastersystem" "megacd" "n64" 
"n64dd" "nes" "ngp"  
"ngpc" "saturn" "sega32x" 
"segacd" "sfc" "snes" 
"snesna" "wonderswan" "wonderswancolor")
declare -a searchFolderList

# File extensions
sevenZipfileextensionWhiteList=("ngp" "ngc" "a26" 
"lnx" "ws" "pc2" 
"wsc" "ngc" "n64" 
"ndd" "v64" "z64" 
"gb" "dmg" "gba" 
"gbc" "nes" "fds" 
"unf" "unif" "bs" 
"fig" "sfc" "smc" 
"swx" "32x" "gg" 
"gen" "md" "smd" )

#executables
chdPath="$EMUDECKGIT/tools/chdconv"
chmod +x "$chdPath/chdman5"
chmod +x "$chdPath/ciso"
chmod +x "$chdPath/3dstool"
chmod +x "$chdPath/extract-xiso"
# chdman5 compiled on January 28th, 2024
# extract-xiso compiled on January 28th, 2024
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
		echo "Converting $file to CHD using the createcd flag."
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

compressCHDDVD() {
	local file=$1
	local successful='' 
	chdman5 createdvd -i "$file" -o "${file%.*}.chd" && successful="true"
	if [[ $successful == "true" ]]; then
		echo "Converting $file to CHD using the createdvd flag."
		echo "successfully created ${file%.*}.chd"
		rm -f "$file"
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

trim3ds() {
	local file=$1
	local successful=''
	# Rename trimmed files to *(Trimmed).3ds
	3dstool -r -f "$file" && successful="true"
	if [[ $successful == "true" ]]; then
		echo "$file succesfully converted to ${file%.*}.3ds"
		mv "$file" "${file%%.*}(Trimmed).3ds"
	else
		echo "error converting $file"
	fi

}

compressXISO() {
	local file=$1
	local successful=''
	local xisoDir=""
	xisoDir="$(dirname "${file}")"
	extract-xiso -r "$file" -d "$xisoDir" && successful="true"
	if [[ $successful == "true" ]]; then
		echo "$file succesfully converted to ${file%.*}.xiso.iso"
		mv "$file" "${file%%.*}.xiso.iso"
		rm -f "${file%%.*}.iso.old"
	else
		echo "error converting $file"
	fi

}

	compress7z() {
	local sevenZipDir=""
	sevenZipDir="$(dirname "${file}")"
	local file=$1
	local successful=''
	local ext=$(echo "${file##*.}" | awk '{print tolower($0)}')
	7z a -mx=9 "${file%.*}.7z" "$file" && successful="true"
	if [[ $successful == "true" ]]; then
		echo "$file succesfully compressed to ${file%.*}.7z"
		#mv "$file" "${file%%.*}.xiso.iso"
		rm -f "${file%%.*}.$ext"
	else
		echo "error converting $file"
	fi

}

#main
#text="$(printf "<b>Hi</b>\nWelcome to the EmuDeck Compression Tool!\n\nThis tool will compress your ROMs to best optimize your storage. This tool will convert your ROMs to a new file format and delete the original files. Be very careful and make sure you have extensive backups.\n\n<b></b>")"
text="$(printf "<b>Hi</b>\nWelcome to the EmuDeck Compression Tool!\n\nThis tool will compress your ROMs to best optimize your storage. Be very careful and make sure you have extensive backups.\n\nThis tool will scan your selected ROMs folder and compress your ROMs files to the most optimal file format.\n\n<b>The original files will be deleted if compression is successful.</b>")"
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
	for romfolder in "${n3dsfolderWhiteList[@]}"; do
		echo "Checking ${romsPath}/${romfolder}/"
		# ignore trimmed files
		mapfile -t files < <(find "${romsPath}/${romfolder}/" -type f -iname "*.3ds" ! -name "*(Trimmed)*")
		if [ ${#files[@]} -gt 0 ]; then
			echo "found in $romfolder"
			searchFolderList+=("$romfolder")
		fi
	done
	for romfolder in "${csofolderWhiteList[@]}"; do
		echo "Checking ${romsPath}/${romfolder}/"
		mapfile -t files < <(find "${romsPath}/${romfolder}/" -type f -iname "*.iso")
		if [ ${#files[@]} -gt 0 ]; then
			echo "found in $romfolder"
			searchFolderList+=("$romfolder")
		fi
	done
	for romfolder in "${xboxfolderWhiteList[@]}"; do
		echo "Checking ${romsPath}/${romfolder}/"
		mapfile -t files < <(find "${romsPath}/${romfolder}/" -type f -iname "*.iso" ! -iname '*.xiso.iso')
		if [ ${#files[@]} -gt 0 ]; then
			echo "found in $romfolder"
			searchFolderList+=("$romfolder")
		fi
	done
	if which "7za" > /dev/null 2>&1; then #ensure tools are in place
		echo "7za found"
		for romfolder in "${sevenZipfolderWhiteList[@]}"; do
			echo "Checking ${romsPath}/${romfolder}/"
			mapfile -t files < <(find "${romsPath}/${romfolder}/" -type f -iname "*.ngp" -o -type f -iname "*.ngc" -o -type f -iname "*.a26" -o -type f -iname "*.lnx" -o -type f -iname "*.ws" -o -type f -iname "*.pc2" -o -type f -iname "*.wsc" -o -type f -iname "*.ngc" -o -type f -iname "*.n64" -o -type f -iname "*.ndd" -o -type f -iname "*.v64" -o -type f -iname "*.z64" -o -type f -iname "*.gb" -o -type f -iname "*.dmg" -o -type f -iname "*.gba" -o -type f -iname "*.gbc" -o -type f -iname "*.nes" -o -type f -iname "*.fds" -o -type f -iname "*.unf" -o -type f -iname "*.unif" -o -type f -iname "*.bs" -o -type f -iname "*.fig" -o -type f -iname "*.sfc" -o -type f -iname "*.smc" -o -type f -iname "*.swx" -o -type f -iname "*.32x" -o -type f -iname "*.gg" -o -type f -iname "*.gen" -o -type f -iname "*.md" -o -type f -iname "*.smd")
			if [ ${#files[@]} -gt 0 ]; then
				echo "found in $romfolder"
				searchFolderList+=("$romfolder")
			fi
		done	
	fi

	if ((${#searchFolderList[@]} == 0)); then
		echo "No eligible files found."
		text="$(printf "<b>No suitable ROMs were found for conversion.")"
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
	text="$(printf "Which folders do you want to convert?")"
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
					echo "Converting: $f"
					compressCHD "$f"
			done
			find "$romsPath/$romfolder" -type f -iname "*.iso" | while read -r f; do
				echo "Converting: $f"
				compressCHDDVD "$f"
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
			text="$(printf "Would you like to compress your PlayStation Portable ROM(s) to CHD or CSO?")"
			pspBulkSelection=$(zenity --question \
				--title="PSP Compression" \
				--width=250 \
				--ok-label="CHD" \
				--extra-button="CSO" \
				--cancel-label="Cancel" \
				--text="${text}" 2>/dev/null && echo "CHD")	
			find "$romsPath/$romfolder" -type f -iname "*.iso" | while read -r f; do			
						if [ "$pspBulkSelection" == "CHD" ]; then
							find "$romsPath/$romfolder" -type f -iname "*.iso" | while read -r f; do
								echo "Converting: $f"
								compressCHDDVD "$f"
							done
						elif [ "$pspBulkSelection" == "CSO" ]; then
							find "$romsPath/$romfolder" -type f -iname "*.iso" | while read -r f; do
								echo "Converting: $f"
								compressCSO "$f"
							done	
						else 
							echo "No valid ROM found"
							exit	
						fi
			done
		fi
	done

	#3ds
	for romfolder in "${romfolders[@]}"; do
		if [[ " ${n3dsfolderWhiteList[*]} " =~ " ${romfolder} " ]]; then
			# Ignore trimmed files
			find "$romsPath/$romfolder" -type f -iname "*.3ds" ! -name '*(Trimmed)*' | while read -r f; do
				echo "Converting: $f"
				trim3ds "$f"
			done
		fi
	done

	for romfolder in "${romfolders[@]}"; do
		if [[ " ${xboxfolderWhiteList[*]} " =~ " ${romfolder} " ]]; then
			find "$romsPath/$romfolder" -type f -iname "*.iso" ! -name '*.xiso.iso' | while read -r f; do
				echo "Converting: $f"
				compressXISO "$f" 
			done
		fi
	done

	for romfolder in "${romfolders[@]}"; do
		if [[ " ${sevenZipfolderWhiteList[*]} " =~ " ${romfolder} " ]]; then
			find "$romsPath/$romfolder" -type f -iname "*.ngp" -o -type f -iname "*.ngc" -o -type f -iname "*.a26" -o -type f -iname "*.lnx" -o -type f -iname "*.ws" -o -type f -iname "*.pc2" -o -type f -iname "*.wsc" -o -type f -iname "*.ngc" -o -type f -iname "*.n64" -o -type f -iname "*.ndd" -o -type f -iname "*.v64" -o -type f -iname "*.z64" -o -type f -iname "*.gb" -o -type f -iname "*.dmg" -o -type f -iname "*.gba" -o -type f -iname "*.gbc" -o -type f -iname "*.nes" -o -type f -iname "*.fds" -o -type f -iname "*.unf" -o -type f -iname "*.unif" -o -type f -iname "*.bs" -o -type f -iname "*.fig" -o -type f -iname "*.sfc" -o -type f -iname "*.smc" -o -type f -iname "*.swx" -o -type f -iname "*.32x" -o -type f -iname "*.gg" -o -type f -iname "*.gen" -o -type f -iname "*.md" -o -type f -iname "*.smd" | while read -r f; do
				echo "Converting: $f"
				compress7z "$f"
			done
		fi
	done


elif [ "$selection" == "Pick a file" ]; then

	while true; do
		selectedCompressionMethod=$(zenity --list --title="Select Option" --text="Select a compression method from the list below." --column="Options" "Compress a ROM to RVZ" "Compress a ROM to CHD" "Compress a ROM to CSO" "Compress a ROM to XISO" "Compress a ROM to 7zip" "Trim a 3DS ROM" --width=300 --height=400)
		if [ $? -eq 1 ]; then
			echo "Compression canceled."
			exit 1
		fi

		if [ -n "$selectedCompressionMethod" ]; then
			break 
		else
			zenity --error --text="Please select a compression method."
		fi
	done
		
	echo "Selected: $selectedCompressionMethod"
	
	#/bin/bash
	f=$(zenity --file-selection --file-filter='ROM File Formats 
	(cue,gdi,iso,gcm,3ds) | *.cue *.gdi *.iso *.gcm *.3ds 
	*.CUE *.GDI *.ISO *.GCM *.3DS *.sfc *.SFC *.ngp *.NGP *.ngc 
	*.NGC *.a26 *.A26 *.lnx *.LNX *.ws *.WS *.pc2 *.PC2
	*.wsc *.WSC *.ngc *.NGC *.n64 *.N64 *.ndd *.NDD *.v64 
	*.V64 *.z64 *.Z64 *.gb *.GB *.dmg *.DMG *.gba *.GBA
	*.gbc *.GBC *.nes *.NES *.fds *.FDS *.unf *.UNF *.unif
	*.UNIF *.bs *.BS *.fig *.FIG *.sfc *.SFC *.smc *.SMC 
	*.swx *.SWX *.32x *.32X *.gg *.GG *.gen *.GEN *.md *.MD 
	*.smd *.SMD' --file-filter='All files | *' 2>/dev/null)
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

	3ds)
		echo 3ds
		;;
	esac



	if [ "$selectedCompressionMethod" == "Compress a ROM to RVZ" ]; then	
		if [[ "$ext" =~ "iso" || "$ext" =~ "ISO" || "$ext" =~ "gcm" || "$ext" =~ "GCM"  ]]; then
			echo "Valid ROM found, compressing $f to RVZ"
			compressRVZ "$f"
		else
			echo "No valid ROM found"
		fi
	elif [ "$selectedCompressionMethod" == "Compress a ROM to CHD" ]; then	
		if [[ "$ext" =~ "iso" || "$ext" =~ "ISO" ]]; then
			echo "Valid $ext ROM found, compressing $f to CHD"
			compressCHDDVD "$f"
		elif [[ "$ext" =~ "gdi"  || "$ext" =~ "GDI" || "$ext" =~ "cue" || "$f" =~ "CUE" ]]; then
			echo "Valid $ext ROM found, compressing $f to CHD"
			compressCHD "$f" 
		else 
			echo "No valid ROM found"			
		fi
	elif [ "$selectedCompressionMethod" == "Compress a ROM to XISO" ]; then	
		if [[ "$ext" =~ "xiso" || "$ext" =~ "XISO" ]]; then
			echo "$f already compressed."
		elif [[ "$ext" =~ "iso" || "$ext" =~ "ISO" ]]; then
			echo "Valid $ext ROM found, compressing $f to xiso"
			compressXISO "$f"
		else 
			echo "No valid ROM found"
		fi
	elif [ "$selectedCompressionMethod" == "Compress a ROM to CSO" ]; then	
		if [[ "$ext" =~ "iso" || "$ext" =~ "ISO" ]]; then
			echo "Valid ROM found, prompting user"

			text="$(printf "Would you like to compress your PlayStation Portable ROM to CSO or CHD?")"
			pspSelection=$(zenity --question \
				--title="PSP Compression" \
				--width=250 \
				--ok-label="CSO" \
				--extra-button="CHD" \
				--cancel-label="Cancel" \
				--text="${text}" 2>/dev/null && echo "CSO")		

			if [ "$pspSelection" == "CSO" ]; then
				echo "Valid $ext ROM found, compressing $f to CSO"
				compressCSO "$f"
			elif [ "$pspSelection" == "CHD" ]; then
				echo "Valid $ext ROM found, compressing $f to CHD"
				compressCHDDVD "$f"
			fi
		else 
			echo "No valid ROM found"
		fi
	elif [ "$selectedCompressionMethod" == "Trim a 3DS ROM" ]; then	
		if [[ "$ext" =~ "(Trimmed)" ]]; then
			echo "$f already trimmed."
		elif [[ "$ext" =~ "3ds" || "$ext" =~ "3DS" ]]; then
			echo "Valid $ext ROM found, trimming $f"
			trim3ds "$f"
		else 
			echo "No valid ROM found"
		fi
	elif [ "$selectedCompressionMethod" == "Compress a ROM to 7zip" ]; then	
		echo "true"
		if [[ " ${sevenZipfileextensionWhiteList[*]} " =~ " ${ext} " ]]; then
			echo "Valid ROM found, compressing $f to 7zip"
			compress7z "$f"	
		else 
			echo "No valid ROM found"
		fi
	else
		echo "No valid ROM found"
	fi

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

	text="$(printf "<b>Done!</b>\n\n If you used Steam ROM Manager previously, you will need to re-parse your games to point to the newly compressed files. Would you like to open Steam ROM Manager now?")"
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
