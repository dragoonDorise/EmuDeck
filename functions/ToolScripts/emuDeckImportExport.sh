#!/bin/bash
function importGetExternalDrives(){
	local dir user
	user="${USER:-$(id -un)}"

	for dir in "/run/media/$user"/* /run/media/* "/media/$user"/* /media/* /mnt/*; do
		[ -d "$dir" ] || continue
		mountpoint -q "$dir" || continue
		printf '%s\n' "$dir"
	done | sort -u
}

function importCustomLocation(){
	local -a drives=()
	local mount label

	while read -r mount; do
		label=$(lsblk -no LABEL "$(findmnt -no SOURCE "$mount")" 2>/dev/null | head -n1)
		drives+=("$mount" "${label:-No label}")
	done < <(importGetExternalDrives)

	if [ ${#drives[@]} -eq 0 ]; then
		zenity --error --text="No external drives found" 2>/dev/null
		return 1
	fi

	zenity --list \
		--title="Select the drive for your backup" \
		--column="Path" --column="Label" \
		--print-column=1 \
		--width=600 --height=300 \
		"${drives[@]}" 2>/dev/null
	
}

function importCheckSpace(){
	local origin=$1
	local destination=$2
	local neededSpace=$(du -s "$origin" | awk '{print $1}')
	local neededSpaceInHuman=$(du -sh "$origin" | awk '{print $1}')
	#File Size on destination
	local freeSpace=$(df -k "$destination" --output=avail | tail -1)
	local freeSpaceInHuman=$(df -kh "$destination" --output=avail | tail -1)
	local difference=$(($freeSpace - $neededSpace))

	if [[ $difference -lt 0 ]]; then
		text="$(printf "Make sure you have enought space in $destination. You need to have at least $neededSpaceInHuman available")"
		zenity --question \
			--title="EmuDeck Import tool" \
			--width=600 \
			--cancel-label="Exit" \
			--ok-label="Continue" \
			--text="${text}" 2>/dev/null
		ans=$?
		if [ $ans -eq 0 ]; then
			echo "Continue..."
		else
			exit
		fi

	else
		echo "Continue..."
	fi
}


function importEmuDeck(){

	text="$(printf "Welcome to EmuDeck's <b>import</b> tool.\nThis script will help you migrate your EmuDeck installation from another device")"

	zenity --question \
		--title="EmuDeck Import tool" \
		--width=600 \
		--cancel-label="Exit" \
		--ok-label="Import EmuDeck Backup" \
		--text="${text}" 2>/dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		echo "Waiting for the user to pick a destination...."
	else
		exit
	fi
	
	origin=$(importCustomLocation) || exit
	[ -z "$origin" ] && exit
	
	origin="$origin/EmuDeckBackup"
	
	[ -d "$origin" ] || { zenity --error --width=350 --text="No EmuDeck backup found on this drive"; exit; }
	
	#Zenity selection menu
	local -a rows=()

	[ -d "$origin/roms" ]   && rows+=(TRUE "Roms")
	[ -d "$origin/bios" ]   && rows+=(TRUE "Bios")
	[ -d "$origin/saves" ]   && rows+=(TRUE "Saves")
	[ -d "$origin/storage" ]   && rows+=(TRUE "Storage")

	if [ -d "$origin/tools/downloaded_media" ]; then
		rows+=(TRUE "ES-DE Media")
	fi
	
	[ ${#rows[@]} -eq 0 ] && { zenity --error --width=350 --text="No EmuDeck backup found on this drive"; exit; } 

	selection=$(zenity --list --checklist \
		--title="EmuDeck Restore" \
		--text="Select what you want to import. This will overwrite all files" \
		--column="" --column="Item" \
		--separator="|" \
		--width=500 --height=400 \
		"${rows[@]}" \
		2>/dev/null)
	rc=$?
	[ $rc -ne 0 ] && exit
	[ -z "$selection" ] && exit
	IFS='|' read -ra items <<< "$selection"

	for item in "${items[@]}"; do
		case "$item" in
			"Saves")
				importCheckSpace "$origin/saves" "$emulationPath"

				rsync -rav --progress "$origin/saves/" "$emulationPath/saves/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Importing from $origin/saves/" --title="Importing saves..." --width=600 --percentage=0 --auto-close
				
				;;
			"Storage")
				importCheckSpace "$origin/storage/" "$emulationPath"

				rsync -rav --progress "$origin/storage/" "$emulationPath/storage/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Importing files from $origin/storage/" --title="Importing files..." --width=600 --percentage=0 --auto-close

				;;
			"ES-DE Media")

				importCheckSpace "$origin/tools/downloaded_media" "$emulationPath"
				mkdir -p "$ESDEscrapData"
				rsync -rav --progress  "$origin/tools/downloaded_media/" "$ESDEscrapData/"| awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Importing files from $origin/tools/downloaded_media/" --title="Importing files..." --width=600 --percentage=0 --auto-close
				
				;;
			"Bios")
				importCheckSpace "$origin/bios/" "$emulationPath"

				rsync -rav --progress "$origin/bios/" "$emulationPath/bios/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Importing files from $origin/bios/" --title="Importing files..." --width=600 --percentage=0 --auto-close

				;;
			"Roms")
				importCheckSpace "$origin/roms/" "$emulationPath"

				rsync -rav --progress --exclude='*.txt' "$origin/roms/" "$emulationPath/roms/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Importing roms from $origin/roms/" --title="Importing roms..." --width=600 --percentage=0 --auto-close
			;;
		esac
	done

	text="$(printf "<b>Success!</b>\nRemember that you need to run Steam Rom Manager in this new device to add any of your games to Steam")"
	 zenity --info \
	--title="EmuDeck Import tool" \
	--width=350 \
	--text="${text}"


}


function exportEmuDeck(){

	text="$(printf "Welcome to EmuDeck's <b>export</b> tool.\nThis script will help you migrate your EmuDeck installation to another device")"

	zenity --question \
		--title="EmuDeck Export tool" \
		--width=600 \
		--cancel-label="Exit" \
		--ok-label="Export EmuDeck Backup" \
		--text="${text}" 2>/dev/null
	ans=$?
	if [ $ans -eq 0 ]; then
		echo "Waiting for the user to pick a destination...."
	else
		exit
	fi
	
	destination=$(importCustomLocation) || exit
	[ -z "$destination" ] && exit
	[ "$destination/Emulation" == "$emulationPath" ] && exit
	
	
	#Zenity selection menu
	local -a rows=()

	rows+=(TRUE "Roms")
	rows+=(TRUE "Bios")
	rows+=(TRUE "Saves")
	rows+=(TRUE "Storage")

	if [ -d "$ESDEscrapData" ]; then
		rows+=(TRUE "ES-DE Media")
	fi

	selection=$(zenity --list --checklist \
		--title="EmuDeck Export" \
		--text="Select what you want to back up. This will overwrite all files" \
		--column="" --column="Item" \
		--separator="|" \
		--width=500 --height=400 \
		"${rows[@]}" \
		2>/dev/null)
	rc=$?
	[ $rc -ne 0 ] && exit
	[ -z "$selection" ] && exit
	IFS='|' read -ra items <<< "$selection"

	for item in "${items[@]}"; do
		case "$item" in
			"Saves")
				importCheckSpace "$emulationPath/saves/" "$destination"

				mkdir -p "$destination/EmuDeckBackup/saves"

				rsync -ravL --progress -m "$emulationPath/saves/" "$destination/EmuDeckBackup/saves/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Exporting saves to $destination/EmuDeckBackup/saves/" --title="Exporting saves..." --width=600 --percentage=0 --auto-close
				;;
			"Storage")
				importCheckSpace "$emulationPath/storage/" "$destination"

				mkdir -p "$destination/EmuDeckBackup/storage"

				rsync -ravL --progress -m "$emulationPath/storage/" "$destination/EmuDeckBackup/storage/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Exporting files to $destination/EmuDeckBackup/storage/" --title="Exporting files..." --width=600 --percentage=0 --auto-close

				;;
			"ES-DE Media")

				importCheckSpace "$ESDEscrapData" "$destination"

				mkdir -p "$destination/EmuDeckBackup/tools/downloaded_media"

				rsync -ravL --progress -m "$ESDEscrapData/" "$destination/EmuDeckBackup/tools/downloaded_media/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Exporting files to $destination/EmuDeckBackup/tools/downloaded_media/" --title="Exporting files..." --width=600 --percentage=0 --auto-close
				
				;;
			"Bios")
				importCheckSpace "$emulationPath/bios/" "$destination"

				mkdir -p "$destination/EmuDeckBackup/bios"

				rsync -ravL --progress -m "$emulationPath/bios/" "$destination/EmuDeckBackup/bios/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Exporting files to $destination/EmuDeckBackup/bios/" --title="Exporting files..." --width=600 --percentage=0 --auto-close

				;;
			"Roms")
				importCheckSpace "$emulationPath/roms/" "$destination"

				mkdir -p "$destination/EmuDeckBackup/roms"

				rsync -ravL --progress -m --exclude='*.txt' "$emulationPath/roms/" "$destination/EmuDeckBackup/roms/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Exporting roms to $destination/EmuDeckBackup/roms/" --title="Exporting roms..." --width=600 --percentage=0 --auto-close
			;;
		esac
	done

	text="$(printf "<b>Success!</b>\nNow it's time to:\n1 Install EmuDeck in your new device. \n2 Use the Import Tool in your new device. \n3 That's all :)")"
	 zenity --info \
	--title="EmuDeck Export tool" \
	--width=350 \
	--text="${text}"


}
