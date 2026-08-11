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
		--title="Select the drive where you want to create your backup" \
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
	
	text="$(printf "Please select the drive where you have your <b>backup</b>")"
	 zenity --info \
	--title="EmuDeck Import tool" \
	--width="600" \
	--text="${text}" 2>/dev/null
	
	origin=$(importCustomLocation)
	
	if [ -d "$origin/EmuDeckBackup/saves/" ]; then
		echo "Continue..."
	else
		text="$(printf "<b>No saved games detected</b>\nPlease select the root of the drive, don't select any of its folders.")"
		zenity --error \
		 --title="EmuDeck Import tool" \
		 --width=250 \
		 --ok-label="Try again" \
		 --text="${text}"
	
		 if [ -d "$origin/EmuDeckBackup/saves/" ]; then
			 echo "Continue..."
		 else
			 text="$(printf "<b>No EmuDeck save folder found</b>\nMake sure you have an Emulation/saves folder in your drive")"
			 zenity --error \
			  --title="EmuDeck Import tool" \
			  --width=250 \
			  --ok-label="Bye" \
			  --text="${text}"
			  exit
		 fi
	fi
	
	importCheckSpace "$origin/EmuDeckBackup/saves/" "$emulationPath"
	
	for entry in "$origin/EmuDeckBackup/saves/"*
	do
		rsync -rav --progress "$entry" "$emulationPath/saves/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Importing $entry to $emulationPath/saves/" --title="Importing $entry..." --width=600 --percentage=0 --auto-close
	done
	
	
	size=0;
	size=$((size + $(du -sb "$origin/EmuDeckBackup/saves/" | cut -f1)))
	if [ "$size" -gt 4096 ]; then
		if [ -d "$origin/EmuDeckBackup/storage" ]; then
			text="$(printf "<b>Storage folder found in your drive!</b>\nLet's import that one too")"
			zenity --question \
				--title="EmuDeck Import tool" \
				--width=600 \
				--cancel-label="Exit" \
				--ok-label="Import my storage" \
				--text="${text}" 2>/dev/null
			ans=$?
			if [ $ans -eq 0 ]; then
	
				importCheckSpace "$origin/EmuDeckBackup/storage/" "$emulationPath"
	
				for entry in "$origin/EmuDeckBackup/storage/"*
				do
					rsync -ravL --progress "$entry" "$emulationPath/storage/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Importing $entry to $emulationPath/storage/" --title="Importing $entry..." --width=600 --percentage=0 --auto-close
				done
	
			else
				echo "User selected no import: Storage"
			fi
	
		fi
	
		if [ -d "$origin/EmuDeckBackup/bios" ]; then
			text="$(printf "<b>Bios folder found in your drive!</b>\nLet's import that one too")"
			zenity --question \
				--title="EmuDeck Import tool" \
				--width=600 \
				--cancel-label="No" \
				--ok-label="Import my Bios" \
				--text="${text}" 2>/dev/null
			ans=$?
			if [ $ans -eq 0 ]; then
	
				importCheckSpace "$origin/EmuDeckBackup/bios/" "$emulationPath"
	
				for entry in "$origin/EmuDeckBackup/bios/"*
				do
					rsync -ravL --progress "$entry" "$emulationPath/bios/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Importing $entry to $emulationPath/bios/" --title="Importing $entry..." --width=600 --percentage=0 --auto-close
				done
	
			else
				echo "User selected no import: bios"
			fi
	
		fi
	
	
		if [ -d "$origin/EmuDeckBackup/tools/downloaded_media" ]; then
			text="$(printf "<b>ESDE Media folder found in your drive!</b>\nLet's import that one too")"
			zenity --question \
				--title="EmuDeck Import tool" \
				--width=600 \
				--cancel-label="No" \
				--ok-label="Import my ESDE media" \
				--text="${text}" 2>/dev/null
			ans=$?
			if [ $ans -eq 0 ]; then
	
				importCheckSpace "$origin/EmuDeckBackup/tools/downloaded_media/" "$toolsPath"
	
				for entry in "$origin/EmuDeckBackup/tools/downloaded_media/"*
				do
					rsync -ravL --progress "$entry" "$emulationPath/tools/downloaded_media/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Importing $entry to $emulationPath/tools/downloaded_media/" --title="Importing $entry..." --width=600 --percentage=0 --auto-close
				done
	
			else
				echo "User selected no import: ESDE media"
			fi
	
		fi
	
	
	
		if [ -d "$origin/EmuDeckBackup/roms" ]; then
			text="$(printf "<b>Roms folder found in your drive!</b>\nLet's import that one too")"
			zenity --question \
				--title="EmuDeck Import tool" \
				--width=600 \
				--cancel-label="No" \
				--ok-label="Import my Roms" \
				--text="${text}" 2>/dev/null
			ans=$?
			if [ $ans -eq 0 ]; then
	
				importCheckSpace "$origin/EmuDeckBackup/roms/" "$emulationPath"
	
				for entry in "$origin/EmuDeckBackup/roms/"*
				do
					rsync -ravL --progress "$entry" "$emulationPath/roms/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Importing $entry to $emulationPath/roms/" --title="Importing $entry..." --width=600 --percentage=0 --auto-close
				done
	
			else
				echo "User selected no import: Roms"
			fi
	
		fi
	
		text="$(printf "<b>Success!</b>\nRemember that you need to Open EmuDeck and run Steam Rom Manager in this new device to add any of your games to Steam")"
		 zenity --info \
		--title="EmuDeck Import tool" \
		--width=350 \
		--text="${text}"
	
	else
		text="$(printf "<b>The operation failed</b>\nYour saved games might not have been exported.")"
		zenity --error \
		 --title="EmuDeck Import tool" \
		 --width=250 \
		 --ok-label="Bye" \
		 --text="${text}"
	
	fi

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
	[ "$destination/Emulation" == $emulationPath ] && exit
	
	
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
		--title="EmuDeck Backup" \
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

				rsync -ravL --progress "$emulationPath/saves/" "$destination/EmuDeckBackup/saves/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Exporting saves to $destination/EmuDeckBackup/saves/" --title="Exporting saves..." --width=600 --percentage=0 --auto-close
				;;
			"Storage")
				importCheckSpace "$emulationPath/storage/" "$destination"

				mkdir -p "$destination/EmuDeckBackup/storage"

				rsync -ravL --progress "$emulationPath/storage/" "$destination/EmuDeckBackup/storage/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Exporting files to $destination/EmuDeckBackup/storage/" --title="Exporting files..." --width=600 --percentage=0 --auto-close

				;;
			"ES-DE Media")

				importCheckSpace "$ESDEscrapData" "$destination"

				mkdir -p "$destination/EmuDeckBackup/tools/downloaded_media"

				rsync -ravL --progress "$ESDEscrapData/" "$destination/EmuDeckBackup/tools/downloaded_media/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Exporting files to $destination/EmuDeckBackup/tools/downloaded_media/" --title="Exporting files..." --width=600 --percentage=0 --auto-close
				
				;;
			"Bios")
				importCheckSpace "$emulationPath/bios/" "$destination"

				mkdir -p "$destination/EmuDeckBackup/bios"

				rsync -ravL --progress "$emulationPath/bios/" "$destination/EmuDeckBackup/bios/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Exporting files to $destination/EmuDeckBackup/bios/" --title="Exporting files..." --width=600 --percentage=0 --auto-close

				;;
			"Roms")
				importCheckSpace "$emulationPath/roms/" "$destination"

				mkdir -p "$destination/EmuDeckBackup/roms"

				rsync -ravL --progress "$emulationPath/roms/" "$destination/EmuDeckBackup/roms/" | awk -f $emudeckBackend/rsync.awk | zenity --progress --text="Exporting roms to $destination/EmuDeckBackup/roms/" --title="Exporting roms..." --width=600 --percentage=0 --auto-close
			;;
		esac
	done

	text="$(printf "<b>Success!</b>\nNow it's time to:\n1 Install EmuDeck in your new device. \n2 Use the Import Tool in your new device. \n3 That's all :)")"
	 zenity --info \
	--title="EmuDeck Export tool" \
	--width=350 \
	--text="${text}"


}
