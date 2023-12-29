#!/bin/bash
clear
if [ ! -f "$HOME/.config/EmuDeck/backend/functions/all.sh" ]; then
 text="$(printf "<b>EmuDeck installation not found</b>")"
 zenity --error \
	 --title="EmuDeck Export tool" \
	 --width=250 \
	 --ok-label="Bye" \
	 --text="${text}" 2>/dev/null
 exit
fi
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
function customLocation(){
	zenity --file-selection --directory --title="Select the root of the drive with your backup" 2>/dev/null
}
function checkSpace(){
	local origin=$1
	local destination=$2
	local neededSpace=$(du -s "$emulationPath/saves" | awk '{print $1}')
	local neededSpaceInHuman=$(du -sh "$origin" | awk '{print $1}')
	#File Size on destination
	local freeSpace=$(df -k "$destination" --output=avail | tail -1)
	local freeSpaceInHuman=$(df -kh "$destination" --output=avail | tail -1)
	local difference=$(($freeSpace - $neededSpace))

	if [[ $difference -lt 0 ]]; then
		text="$(printf "Make sure you have enought space in $destination. You need to have at least $neededSpaceInHuman available")"
		zenity --question \
			--title="EmuDeck Export tool" \
			--width=450 \
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

text="$(printf "Welcome to EmuDeck's <b>export</b> tool.\nThis script will help you migrate your EmuDeck saved games to another Steam Deck")"

zenity --question \
	--title="EmuDeck Export tool" \
	--width=450 \
	--cancel-label="Exit" \
	--ok-label="Export my saved games" \
	--text="${text}" 2>/dev/null
ans=$?
if [ $ans -eq 0 ]; then
	echo "Waiting for the user to pick a destination...."
else
	exit
fi

text="$(printf "Please pick the drive to export your saves.\n<b>Pick the root of the device, don't pick any subdirectory</b>")"
 zenity --info \
--title="EmuDeck Export tool" \
--width="${width}" \
--text="${text}" 2>/dev/null

destination=$(customLocation)
checkSpace "$emulationPath/saves/" "$destination"

mkdir -p "$destination/EmuDeck/saves"

for entry in "$emulationPath/saves/"*
do
	rsync -ravL --ignore-existing --progress "$entry" "$destination/EmuDeck/saves/" | awk -f $HOME/.config/EmuDeck/backend/rsync.awk | zenity --progress --text="Exporting $entry to $destination/EmuDeck/saves/" --title="Exporting $entry..." --width=400 --percentage=0 --auto-close
done



size=0;
size=$((size + $(du -sb "$destination/EmuDeck/saves/" | cut -f1)))
if [ "$size" -gt 4096 ]; then
	if [ -d "$emulationPath/storage" ]; then
		text="$(printf "<b>Storage folder found in your internal Drive!</b>\nLet's export that one too")"
		zenity --question \
			--title="EmuDeck Export tool" \
			--width=450 \
			--cancel-label="No" \
			--ok-label="Export my storage" \
			--text="${text}" 2>/dev/null
		ans=$?
		if [ $ans -eq 0 ]; then

			checkSpace "$emulationPath/storage/" "$destination"

			mkdir -p "$destination/EmuDeck/storage"

			for entry in "$emulationPath/storage/"*
			do
				rsync -ravL --ignore-existing --progress "$entry" "$destination/EmuDeck/storage/" | awk -f $HOME/.config/EmuDeck/backend/rsync.awk | zenity --progress --text="Exporting $entry to $destination/EmuDeck/storage/" --title="Exporting $entry..." --width=400 --percentage=0 --auto-close
			done

		else
			echo "no storage"
		fi

	fi

	if [ -d "$emulationPath/bios" ]; then
		text="$(printf "Do you want to export all your bios?")"
		zenity --question \
			--title="EmuDeck Export tool" \
			--width=450 \
			--cancel-label="No" \
			--ok-label="Export my bios" \
			--text="${text}" 2>/dev/null
		ans=$?
		if [ $ans -eq 0 ]; then

			checkSpace "$emulationPath/bios/" "$destination"

			mkdir -p "$destination/EmuDeck/bios"

			for entry in "$emulationPath/bios/"*
			do
				rsync -ravL --ignore-existing --progress "$entry" "$destination/EmuDeck/bios/" | awk -f $HOME/.config/EmuDeck/backend/rsync.awk | zenity --progress --text="Exporting $entry to $destination/EmuDeck/bios/" --title="Exporting $entry..." --width=400 --percentage=0 --auto-close
			done

		else
			echo "no bios"
		fi
	fi

	if [ -d "$emulationPath/bios" ]; then
		text="$(printf "Do you want to export all your roms?")"
		zenity --question \
			--title="EmuDeck Export tool" \
			--width=450 \
			--cancel-label="No" \
			--ok-label="Export my roms" \
			--text="${text}" 2>/dev/null
		ans=$?
		if [ $ans -eq 0 ]; then

			checkSpace "$emulationPath/roms/" "$destination"

			mkdir -p "$destination/EmuDeck/roms"

			for entry in "$emulationPath/roms/"*
			do
				rsync -ravL --ignore-existing --progress "$entry" "$destination/EmuDeck/roms/" | awk -f $HOME/.config/EmuDeck/backend/rsync.awk | zenity --progress --text="Exporting $entry to $destination/EmuDeck/roms/" --title="Exporting $entry..." --width=400 --percentage=0 --auto-close
			done

		else
			echo "no roms"
		fi
	fi

	text="$(printf "<b>Success!</b>\nNow it's time to:\n1 Install EmuDeck in your new Deck. \n2 Use the Import Tool in your new Deck. \n3 That's all :)")"
	 zenity --info \
	--title="EmuDeck Export tool" \
	--width=350 \
	--text="${text}"

else
	text="$(printf "<b>The operation failed</b>\nYour saved games might not have been exported.")"
	zenity --error \
	 --title="EmuDeck Export tool" \
	 --width=250 \
	 --ok-label="Bye" \
	 --text="${text}"

fi