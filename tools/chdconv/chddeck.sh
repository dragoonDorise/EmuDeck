#!/bin/bash
# shellcheck source=/home/deck/emudeck/settings.sh
. ~/emudeck/settings.sh

if [[ "$EMUDECKGIT" == "" ]]; then
    EMUDECKGIT="$HOME/.config/EmuDeck/backend"
fi

#whitelist
chdfolderWhiteList=("3do" "amiga" "amiga1200" "amiga600"
"amigacd32" "atomiswave" "cdimono1"
"cdtv" "dreamcast" "genesis"
"genesiswide" "megacd" "megacdjp"
"megadrive" "megadrivejp" "naomi"
"naomi2" "naomigd" "neogeocd"
"neogeocdjp" "pcenginecd" "pcfx"
"ps2" "psx" "saturn"
"saturnjp" "sega32x" "sega32xjp"
"sega32xna" "segacd" "tg-cd"
"tg16")
rvzfolderWhiteList=("gc" "wii" "primehacks")
csofolderWhiteList=("psp")
n3dsfolderWhiteList=("n3ds")
xboxfolderWhiteList=("xbox")
sevenzipfolderWhiteList=("atari2600" "atarilynx" "famicom" "gamegear"
"gb" "gbc" "gba"
"genesis" "mastersystem" "megacd"
"n64" "n64dd" "nes"
"ngp"  "ngpc" "saturn"
"sega32x" "segacd" "sfc"
"snes" "snesna" "wonderswan"
"wonderswancolor")
declare -a searchFolderList

# File extensions
chdFileExtensions=("gdi" "cue" "iso" "chd")
rvzFileExtensions=("gcm" "iso" "rvz")
csoFileExtensions=("iso" "cso")
xboxFileExtensions=("iso")
n3dsFileExtensions=("3ds")
sevenzipFileExtensions=("ngp" "ngc" "a26"
"lnx" "ws" "pc2"
"wsc" "ngc" "n64"
"ndd" "v64" "z64"
"gb" "dmg" "gba"
"gbc" "nes" "fds"
"unf" "unif" "bs"
"fig" "sfc" "smc"
"swx" "32x" "gg"
"gen" "md" "smd" )


combinedFileExtensions=(
"${n3dsFileExtensions[@]}" 
"${chdFileExtensions[@]}" 
"${rvzFileExtensions[@]}" 
"${rvzFileExtensions[@]}" 
"${csoFileExtensions[@]}" 
"${xboxFileExtensions[@]}"
"${sevenzipFileExtensions[@]}")

#executables
chdPath="$EMUDECKGIT/tools/chdconv"
chmod +x "$chdPath/chdman5"
chmod +x "$chdPath/ciso"
chmod +x "$chdPath/3dstool"
chmod +x "$chdPath/extract-xiso"
# chdman5 compiled on March 6th, 2024
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
		echo "$file succesfully converted to ${file%.*}.chd"
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
	chdman5 createdvd -i "$file" -o "${file%.*}.chd" -c zstd && successful="true"
	if [[ $successful == "true" ]]; then
		echo "Converting $file to CHD using the createdvd flag and hunksize 16348."
		echo "$file succesfully converted to ${file%.*}.chd"
		rm -f "$file"
	else
		echo "Conversion of ${file} failed."
		rm -f "${file%.*}.chd"
	fi

}

compressCHDDVDLowerHunk() {
	local file=$1
	local successful='' 
	chdman5 createdvd --hunksize 2048 -i "$file" -o "${file%.*}.chd" && successful="true"
	if [[ $successful == "true" ]]; then
		echo "Converting $file to CHD using the createdvd flag and hunksize 2048."
		echo "$file succesfully converted to ${file%.*}.chd"
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
		echo "Successfully trimmed ${file%.*}.3ds"
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
		rm -f "$file"
	else
		echo "error converting $file"
	fi

}

decompressCHDISO() {

	local file=$1
	local successful='' 
	chdman5 extractdvd -i "$file" -o "${file%.*}.iso" && successful="true"
	if [[ $successful == "true" ]]; then
		echo "Decompressing $file to ISO using the extractdvd flag."
		echo "$file succesfully decompressed to ${file%.*}.iso"
		rm -f "$file"
	else
		echo "Conversion of ${file} failed."
		rm -f "${file%.*}.iso"
	fi

}

decompressCSOISO() {

	local file=$1
	local successful=''
	ciso 0 "$file" "${file%.*}.iso" && successful="true"
	if [[ $successful == "true" ]]; then
		echo "$file succesfully converted to ${file%.*}.iso"
		rm -f "$file"
	else
		echo "error converting $file"
		rm -f "${file%.*}.iso"
	fi

}

decompressRVZ() {
	local file=$1
	local successful=''
	${dolphintool} convert -f iso -b 131072 -c zstd -l 5 -i "$file" -o "${file%.*}.iso" && successful="true"
	if [[ $successful == "true" ]]; then
		echo "$file succesfully decompressed to ${file%.*}.iso"
		rm -f "$file"
	else
		echo "error converting $file"
		rm -f "${file%.*}.iso"
	fi
}

#main
#text="$(printf "<b>Hi</b>\nWelcome to the EmuDeck Compression Tool!\n\nThis tool will compress your ROMs to best optimize your storage. This tool will convert your ROMs to a new file format and delete the original files. Be very careful and make sure you have extensive backups.\n\n<b></b>")"
while true; do
	text="$(printf "Welcome to the EmuDeck Compression Tool!\n\nThis tool will compress your ROMs to best optimize your storage. Be very careful and make sure you have extensive backups.\n\nThis tool will scan your selected ROMs folder and compress your ROMs files to the most optimal file format.\nThe original files will be deleted if compression is successful.\n\nSelect a compression method from the list below.")"
	selection=$(zenity --list \
		--title="EmuDeck" \
		--width=500 \
		--height=400 \
		--ok-label="Select" \
		--cancel-label="Exit" \
		--column="Options" \
		"Bulk Compression" "Bulk Decompression" "Select a ROM" \
		--text="${text}" 2>/dev/null)
	if [ $? -eq 1 ]; then
		echo "Compression canceled."
		exit 1
	fi

	if [ -n "$selection" ]; then
		break
	else
		zenity --error \
		--text="Please select a compression method." \
		--width=200 \
		--height=100
	fi
done


echo $selection

case $selection in
    "Bulk Compression")
        compressionSelection="Bulk Compression"
        ;;
    "Bulk Decompression")
        compressionSelection="Bulk Decompression"
        ;;
    "Select a ROM")
        compressionSelection="Select a ROM"
        ;;
    *)
        compressionSelection="Exit"
        ;;
esac

echo $compressionSelection

if [ "$selection" == "Bulk Compression" ]; then

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
		for romfolder in "${sevenzipfolderWhiteList[@]}"; do
			echo "Checking ${romsPath}/${romfolder}/"

			mapfile -t files < <(find "${romsPath}/${romfolder}" -type f \( -iname "*.${sevenzipFileExtensions[0]}" $(for extension in "${sevenzipFileExtensions[@]:1}"; do echo ' -o -iname *.'"$extension"; done) \))
			if [ ${#files[@]} -gt 0 ]; then
				echo "found in $romfolder"
				searchFolderList+=("$romfolder")
			fi
		done	
	fi

	if ((${#searchFolderList[@]} == 0)); then
		echo "No eligible files found."
		zenity --error \
			--title="EmuDeck" \
			--width=250 \
			--ok-label="Exit" \
			--text="No suitable ROMs were found for conversion."
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
			--height=600 \
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
				echo "Converting: $f using the createcd flag"
				compressCHD "$f"
			done
			find "$romsPath/$romfolder" -type f -iname "*.cue" | while read -r f; do
				echo "Converting: $f using the createcd flag"
				compressCHD "$f"
			done
			find "$romsPath/$romfolder" -type f -iname "*.iso" | while read -r f; do
				echo "Converting: $f using the createdvd flag"
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
			text="$(printf "Would you like to compress your PlayStation Portable ROM(s) to CSO or CHD?")"
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
							echo "Converting: $f using the createdvd flag  and 2048 hunksize"
							compressCHDDVDLowerHunk "$f"
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
		if [[ " ${sevenzipfolderWhiteList[*]} " =~ " ${romfolder} " ]]; then

			for ext in "${sevenzipFileExtensions[@]}"; do
				find "$romsPath/$romfolder" -type f -iname "*.$ext" | while read -r f; do
					echo "Converting: $f"
					compress7z "$f"
				done
			done
		fi
	done


elif [ "$selection" == "Select a ROM" ]; then
	while true; do
		selectedCompressionMethod=$(zenity --list \
		--title="Select Option" \
		--text="Select a compression method from the list below." \
		--ok-label="Select" \
		--cancel-label="Exit" \
		--column="Options" "Compress a ROM to RVZ" "Compress a ROM to CHD" "Compress a PSP ROM to CHD or CSO" "Compress a ROM to XISO" "Compress a ROM to 7zip" "Trim a 3DS ROM" "Decompress a PSP CHD to ISO" "Decompress a PSP CSO to ISO" "Decompress a GC/Wii RVZ to ISO" --width=300 --height=600)
		if [ $? -eq 1 ]; then
			echo "Compression canceled."
			exit 1
		fi

		if [ -n "$selectedCompressionMethod" ]; then
			break 
		else
			zenity --error \
			--text="Please select a compression method." \
			--width=200 \
			--height=100
		fi
	done
		
	echo "Selected: $selectedCompressionMethod"

	#/bin/bash
	filteredFileFormats=$(printf -- '*.%s ' "${combinedFileExtensions[@]}")
	f=$(zenity --file-selection --file-filter="ROM File Formats | ${filteredFileFormats}" --file-filter='All files | *' 2>/dev/null)

	ext=$(echo "${f##*.}" | awk '{print tolower($0)}')
	romFilePath=$(dirname "$f")
	
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
	chd)
		echo chd
		;;
	rvz)
		echo rvz
		;;
	cso)
		echo cso
		;;
	esac

	if [ "$selectedCompressionMethod" == "Compress a ROM to RVZ" ]; then	
		if [[ "$ext" =~ "iso" || "$ext" =~ "ISO" || "$ext" =~ "gcm" || "$ext" =~ "GCM"  ]]; then
			echo "Valid ROM found, compressing $f to RVZ"
			compressRVZ "$f"
		else
			echo "No valid ROM found"
		fi
	elif [ "$selectedCompressionMethod" == "Decompress a GC/Wii RVZ to ISO" ]; then	
		if [[ "$ext" =~ "rvz" || "$ext" =~ "RVZ" ]]; then
			echo "Valid ROM found, decompressing $f to ISO"
			decompressRVZ "$f"
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
	elif [ "$selectedCompressionMethod" == "Compress a PSP ROM to CHD or CSO" ]; then	
		if [[ "$ext" =~ "iso" || "$ext" =~ "ISO" ]]; then
			echo "Valid ROM found, prompting user"

			text="$(printf "Would you like to compress your PlayStation Portable ROM to CHD or CSO?")"
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
				echo "Valid $ext ROM found, compressing $f to CHD using the createdvd flag and 2048 hunksize."
				compressCHDDVDLowerHunk "$f"
			fi
		else 
			echo "No valid ROM found"
		fi
	elif [ "$selectedCompressionMethod" == "Decompress a PSP CHD to ISO" ]; then
		if [[ "$ext" =~ "chd" || "$ext" =~ "CHD" ]]; then
			echo "Valid $ext ROM found, decompressing $f to ISO using the extractdvd flag."
			decompressCHDISO "$f"
		else 
			echo "No valid ROM found"			
		fi
	elif [ "$selectedCompressionMethod" == "Decompress a PSP CSO to ISO" ]; then
		if [[ "$ext" =~ "cso" || "$ext" =~ "CSO" ]]; then
			echo "Valid $ext ROM found, decompressing $f to ISO."
			decompressCSOISO "$f"
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
		if [[ " ${sevenzipFileExtensions[*]} " =~ " ${ext} " ]]; then
			echo "Valid ROM found, compressing $f to 7zip"
			compress7z "$f"	
		else 
			echo "No valid ROM found"
		fi
	else
		echo "No valid ROM found"
	fi

elif [ "$compressionSelection" == "Bulk Decompression" ]; then

	zenity --info --text="Only GC, Wii, and PSP decompression is supported at this time."

	#find file types we support within whitelist of folders
	for romfolder in "${csofolderWhiteList[@]}"; do
		echo "Checking ${romsPath}/${romfolder}/"
		mapfile -t files < <(find "${romsPath}/${romfolder}/" -type f -iname "*.chd" -o -type f -iname "*.cso")
		if [ ${#files[@]} -gt 0 ]; then
			echo "found in $romfolder"
			searchFolderList+=("$romfolder")
		fi
	done

	if [[ -n "$flatpaktool" ]]; then #ensure tools are in place
		for romfolder in "${rvzfolderWhiteList[@]}"; do
			echo "Checking ${romsPath}/${romfolder}/"
			mapfile -t files < <(find "${romsPath}/${romfolder}/" -type f -iname "*.rvz")
			if [ ${#files[@]} -gt 0 ]; then
				echo "found in $romfolder"
				searchFolderList+=("$romfolder")
			fi
		done
	fi

	if ((${#searchFolderList[@]} == 0)); then
		echo "No eligible files found."
		zenity --error \
			--title="EmuDeck" \
			--width=250 \
			--ok-label="Exit" \
			--text="No suitable ROMs were found for decompression."
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
			--height=500 \
			--ok-label="OK" \
			--cancel-label="Exit" \
			--text="${text}" \
			--checklist \
			--column="" \
			--column=${selectColumnStr}
	) #goddamnit shellcheck broke this. array! do not quote.
	echo "User selected $folderstoconvert" 2>/dev/null

	IFS="|" read -r -a romfolders <<<"$folderstoconvert"



	for romfolder in "${romfolders[@]}"; do
		if [[ " ${csofolderWhiteList[*]} " =~ " ${romfolder} " ]]; then
			find "$romsPath/$romfolder" -type f -iname "*.chd" | while read -r f; do			
				echo "Decompressing $f using the extractdvd flag"
				decompressCHDISO "$f"
			done
		fi
	done

	for romfolder in "${romfolders[@]}"; do
		if [[ " ${csofolderWhiteList[*]} " =~ " ${romfolder} " ]]; then
			find "$romsPath/$romfolder" -type f -iname "*.cso" | while read -r f; do			
				echo "Decompressing $f"
				decompressCSOISO "$f"
			done
		fi
	done

	for romfolder in "${romfolders[@]}"; do
		if [[ " ${rvzfolderWhiteList[*]} " =~ " ${romfolder} " ]]; then
			find "$romsPath/$romfolder" -type f -iname "*.rvz" | while read -r f; do
				echo "Decompressing $f to ISO"
				decompressRVZ "$f"
			done
		fi
	done
else
	exit
fi

echo "All files converted!"

if [ "$uiMode" != 'zenity' ]; then
	text="$(printf " <b>All files have been converted!</b>")"
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
		"${toolsPath}/launchers/srm/steamrommanager.sh"
		exit
	else
		exit
	fi

fi
